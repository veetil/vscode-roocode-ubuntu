#!/bin/bash
# 3_setup_roocode_cli.sh
# This script sets up the Roo Code CLI to work with the virtual display on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Roo Code CLI for Ubuntu..."

# Step 1: Check if Roo Code repository exists
REPO_DIR="/home/ubuntu/LaunchRoo/Roo-Code"
if [ ! -d "$REPO_DIR" ]; then
  echo "Error: Roo Code repository not found at $REPO_DIR"
  exit 1
fi

# Step 2: Create backup of original files
echo "Creating backup of original files..."
if [ -f "$REPO_DIR/evals/apps/cli/src/index.ts" ]; then
  cp "$REPO_DIR/evals/apps/cli/src/index.ts" "$REPO_DIR/evals/apps/cli/src/index.ts.bak"
  echo "Backup created: $REPO_DIR/evals/apps/cli/src/index.ts.bak"
else
  echo "Warning: CLI source file not found at $REPO_DIR/evals/apps/cli/src/index.ts"
  echo "Checking alternative locations..."
  
  # Try to find the file in a different location
  CLI_SRC=$(find "$REPO_DIR" -name "index.ts" -path "*/apps/cli/src/*" | head -n 1)
  if [ -n "$CLI_SRC" ]; then
    echo "Found CLI source file at $CLI_SRC"
    cp "$CLI_SRC" "$CLI_SRC.bak"
    echo "Backup created: $CLI_SRC.bak"
  else
    echo "Error: Could not find CLI source file. Please check the repository structure."
    exit 1
  fi
fi

# Step 3: Modify the VS Code launch command
echo "Modifying VS Code launch command..."
CLI_SRC=${CLI_SRC:-"$REPO_DIR/evals/apps/cli/src/index.ts"}

# Create a patch file for the modifications
cat > ubuntu-cli-patch.diff << 'EOL'
--- index.ts.bak	2025-05-22 12:00:00.000000000 +0000
+++ index.ts	2025-05-22 12:00:00.000000000 +0000
@@ -197,7 +197,10 @@
 	await execa({
 		env: {
 			ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,
+			DISPLAY: process.env.DISPLAY || ":1", // Use the virtual display
 		},
 		shell: "/bin/bash",
 	})`code --disable-workspace-trust -n ${workspacePath}`
 
+	// Give VS Code some time to initialize
+	await new Promise((resolve) => setTimeout(resolve, 3_000))
@@ -210,7 +213,8 @@
 	console.log(`${Date.now()} [cli#runExercise] Connecting to ${taskSocketPath}`)
 	const client = new IpcClient(taskSocketPath)
 
+	const ipcTimeout = process.env.ROO_CODE_IPC_TIMEOUT ? parseInt(process.env.ROO_CODE_IPC_TIMEOUT) : 10_000;
 	try {
-		await pWaitFor(() => client.isReady, { interval: 250, timeout: 5_000 })
+		await pWaitFor(() => client.isReady, { interval: 250, timeout: ipcTimeout })
 		// eslint-disable-next-line @typescript-eslint/no-unused-vars
 	} catch (error) {
EOL

# Apply the patch
echo "Applying patch to $CLI_SRC..."
patch -p0 "$CLI_SRC" ubuntu-cli-patch.diff || {
  echo "Patch failed. Manually modifying the file..."
  
  # Manually modify the file if patch fails
  sed -i 's/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,\n\t\t\tDISPLAY: process.env.DISPLAY || ":1", \/\/ Use the virtual display/g' "$CLI_SRC"
  
  # Add delay after VS Code launch
  sed -i '/code --disable-workspace-trust -n ${workspacePath}`/a\\n\t\/\/ Give VS Code some time to initialize\n\tawait new Promise((resolve) => setTimeout(resolve, 3_000))' "$CLI_SRC"
  
  # Increase IPC timeout
  sed -i 's/await pWaitFor(() => client.isReady, { interval: 250, timeout: 5_000 })/const ipcTimeout = process.env.ROO_CODE_IPC_TIMEOUT ? parseInt(process.env.ROO_CODE_IPC_TIMEOUT) : 10_000;\n\tawait pWaitFor(() => client.isReady, { interval: 250, timeout: ipcTimeout })/g' "$CLI_SRC"
}

echo "Modifications applied to $CLI_SRC"

# Step 4: Update environment variables file
echo "Updating environment variables file..."
ENV_FILE="/home/ubuntu/LaunchRoo/Roo-Code/evals/.env"
if [ -f "$ENV_FILE" ]; then
  # Check if ROO_CODE_IPC_TIMEOUT is already set
  if ! grep -q "ROO_CODE_IPC_TIMEOUT" "$ENV_FILE"; then
    echo "" >> "$ENV_FILE"
    echo "# Ubuntu-specific configuration" >> "$ENV_FILE"
    echo "ROO_CODE_IPC_TIMEOUT=10000" >> "$ENV_FILE"
    echo "Added ROO_CODE_IPC_TIMEOUT to $ENV_FILE"
  else
    echo "ROO_CODE_IPC_TIMEOUT already set in $ENV_FILE"
  fi
  
  # Check if BENCHMARKS_DB_PATH is already set
  if ! grep -q "BENCHMARKS_DB_PATH" "$ENV_FILE"; then
    echo "BENCHMARKS_DB_PATH=file:/home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db" >> "$ENV_FILE"
    echo "Added BENCHMARKS_DB_PATH to $ENV_FILE"
  else
    # Update BENCHMARKS_DB_PATH to use file: protocol
    sed -i 's|BENCHMARKS_DB_PATH=.*|BENCHMARKS_DB_PATH=file:/home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db|' "$ENV_FILE"
    echo "Updated BENCHMARKS_DB_PATH in $ENV_FILE"
  fi
else
  echo "Creating new .env file at $ENV_FILE"
  mkdir -p "$(dirname "$ENV_FILE")"
  cat > "$ENV_FILE" << 'EOL'
# Remote Implementation Configuration
REMOTE_IMPLEMENTATION_SIMULATION_MODE=false
FALLBACK_TO_SIMULATION=false
NEXT_PUBLIC_USE_POLLING=true

# Ubuntu-specific configuration
ROO_CODE_IPC_TIMEOUT=10000
BENCHMARKS_DB_PATH=file:/home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db
EOL
  echo "$ENV_FILE created"
fi

# Step 5: Create run-cli.sh script
echo "Creating CLI wrapper script..."
cat > run-cli.sh << 'EOL'
#!/bin/bash
# run-cli.sh - Run Roo Code CLI with virtual display

# Start Xvfb if not already running
if ! pgrep -x Xvfb > /dev/null; then
  export DISPLAY=:1
  Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
  echo "Started Xvfb with PID $!"
  # Give Xvfb some time to initialize
  sleep 2
fi

# Set environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000

# Create benchmarks.db directory if it doesn't exist
mkdir -p /home/ubuntu/LaunchRoo/Roo-Code/evals
touch /home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db

# Run the CLI
cd /home/ubuntu/LaunchRoo/Roo-Code/evals
pnpm -F @evals/cli run dev run "$@"
EOL
chmod +x run-cli.sh
echo "run-cli.sh created and made executable."

# Step 6: Create test script
echo "Creating test script..."
cat > test-cli.sh << 'EOL'
#!/bin/bash
# test-cli.sh - Test Roo Code CLI with a simple exercise

# Start Xvfb
export DISPLAY=:1
if ! pgrep -x Xvfb > /dev/null; then
  Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
  XVFB_PID=$!
  echo "Started Xvfb with PID $XVFB_PID"
  sleep 2
else
  XVFB_PID=$(pgrep -x Xvfb)
  echo "Using existing Xvfb with PID $XVFB_PID"
fi

# Test VS Code
echo "Testing VS Code..."
code --version
if [ $? -ne 0 ]; then
  echo "VS Code test failed"
  kill $XVFB_PID 2>/dev/null || true
  exit 1
fi

# Create benchmarks.db directory if it doesn't exist
mkdir -p /home/ubuntu/LaunchRoo/Roo-Code/evals
touch /home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db

# Set environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000
export BENCHMARKS_DB_PATH=file:/home/ubuntu/LaunchRoo/Roo-Code/evals/benchmarks.db

# Test CLI with a simple exercise
echo "Testing CLI..."
cd /home/ubuntu/LaunchRoo/Roo-Code/evals
pnpm -F @evals/cli run dev run python hello_world

# Check the result
if [ $? -eq 0 ]; then
  echo "CLI test completed successfully!"
else
  echo "CLI test failed."
fi

# Don't kill Xvfb as it might be used by other processes
echo "Test completed"
EOL
chmod +x test-cli.sh
echo "test-cli.sh created and made executable."

# Step 7: Create README file
echo "Creating README file..."
cat > README-roocode-cli.md << 'EOL'
# Roo Code CLI Setup for Ubuntu

This directory contains scripts to set up the Roo Code CLI to work on Ubuntu with a virtual display.

## Scripts

- `run-cli.sh`: Run Roo Code CLI with virtual display
- `test-cli.sh`: Test Roo Code CLI with a simple exercise

## Usage

1. Run Roo Code CLI:
   ```bash
   ./run-cli.sh python hello_world
   ```

2. Test the CLI:
   ```bash
   ./test-cli.sh
   ```

## Modifications

The following modifications have been made to make Roo Code work on Ubuntu:

1. VS Code launch command modified to use the virtual display
2. Added delay after VS Code launch to give it time to initialize
3. Increased IPC connection timeout to account for potentially slower startup on Ubuntu
4. Created wrapper scripts to set up the environment correctly
5. Set up SQLite database path with proper file: protocol

## Troubleshooting

If you encounter issues with the CLI:

1. Check if Xvfb is running:
   ```bash
   ps aux | grep Xvfb
   ```

2. Verify the DISPLAY environment variable:
   ```bash
   echo $DISPLAY
   ```

3. Check VS Code logs:
   ```bash
   cat ~/.config/Code/logs/main.log
   ```

4. Increase the IPC timeout:
   ```bash
   export ROO_CODE_IPC_TIMEOUT=20000
   ```

5. Run with verbose logging:
   ```bash
   DISPLAY=:1 code --verbose --log debug
   ```
EOL

echo "Roo Code CLI setup completed successfully!"
echo "You can now use the following scripts:"
echo "  - ./run-cli.sh: Run Roo Code CLI with virtual display"
echo "  - ./test-cli.sh: Test Roo Code CLI with a simple exercise"
echo ""
echo "For more information, see README-roocode-cli.md"