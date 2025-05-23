#!/bin/bash
# 3_setup_roocode_cli.sh
# This script sets up the Roo Code repository and modifies the CLI to work with the virtual display on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Roo Code repository and modifying CLI for Ubuntu..."

# Step 1: Use existing Roo Code repository
echo "Using existing Roo Code repository..."
REPO_DIR="/home/ubuntu/LaunchRoo/Roo-Code"

if [ ! -d "$REPO_DIR" ]; then
  echo "Error: Roo Code repository not found at $REPO_DIR"
  exit 1
fi

# Step 2: Install dependencies
echo "Installing dependencies..."
cd "$REPO_DIR"
pnpm install

# Step 3: Create backup of original files
echo "Creating backup of original files..."
if [ -f "evals/apps/cli/src/index.ts" ]; then
  cp evals/apps/cli/src/index.ts evals/apps/cli/src/index.ts.bak
  echo "Backup created: evals/apps/cli/src/index.ts.bak"
fi

# Step 4: Modify the VS Code launch command
echo "Modifying VS Code launch command..."
if [ -f "evals/apps/cli/src/index.ts" ]; then
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
  echo "Applying patch to evals/apps/cli/src/index.ts..."
  patch -p0 evals/apps/cli/src/index.ts ubuntu-cli-patch.diff || {
    echo "Patch failed. Manually modifying the file..."
    
    # Manually modify the file if patch fails
    sed -i 's/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,\n\t\t\tDISPLAY: process.env.DISPLAY || ":1", \/\/ Use the virtual display/g' evals/apps/cli/src/index.ts
    
    # Add delay after VS Code launch
    sed -i '/code --disable-workspace-trust -n ${workspacePath}`/a\\n\t\/\/ Give VS Code some time to initialize\n\tawait new Promise((resolve) => setTimeout(resolve, 3_000))' evals/apps/cli/src/index.ts
    
    # Increase IPC timeout
    sed -i 's/await pWaitFor(() => client.isReady, { interval: 250, timeout: 5_000 })/const ipcTimeout = process.env.ROO_CODE_IPC_TIMEOUT ? parseInt(process.env.ROO_CODE_IPC_TIMEOUT) : 10_000;\n\tawait pWaitFor(() => client.isReady, { interval: 250, timeout: ipcTimeout })/g' evals/apps/cli/src/index.ts
  }
  
  echo "Modifications applied to evals/apps/cli/src/index.ts"
else
  echo "Error: evals/apps/cli/src/index.ts not found. Please check the repository structure."
  exit 1
fi

# Step 5: Update environment variables file
echo "Updating environment variables file..."
cd /home/ubuntu/LaunchRoo

# Add MODEL variable to the .env file
if [ -f "Roo-Code/evals/.env" ]; then
  # Check if MODEL is already defined
  if ! grep -q "^MODEL=" "Roo-Code/evals/.env"; then
    echo -e "\n# Model Configuration\nMODEL=gpt-4" >> "Roo-Code/evals/.env"
    echo "Added MODEL=gpt-4 to Roo-Code/evals/.env"
  else
    echo "MODEL already defined in Roo-Code/evals/.env"
  fi
else
  echo "Error: Roo-Code/evals/.env not found"
  exit 1
fi

# Step 6: Create CLI wrapper script
echo "Creating CLI wrapper script..."
cat > /home/ubuntu/LaunchRoo/ubuntu_roocode_implementation/run-cli.sh << 'EOL'
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

# Run the CLI
cd /home/ubuntu/LaunchRoo/Roo-Code/evals
pnpm cli "$@"
EOL
chmod +x /home/ubuntu/LaunchRoo/ubuntu_roocode_implementation/run-cli.sh
echo "run-cli.sh created and made executable."

# Step 7: Create a test script
echo "Creating test script..."
cat > /home/ubuntu/LaunchRoo/ubuntu_roocode_implementation/test-roocode-cli.sh << 'EOL'
#!/bin/bash
# test-roocode-cli.sh - Test Roo Code CLI with a simple exercise

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

# Export environment variables
cd /home/ubuntu/LaunchRoo
source ./export-env.sh

# Set additional environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000

# Verify key environment variables
echo -e "\nVerification:"
echo "PYTHON_BACKEND_URL: $PYTHON_BACKEND_URL"
echo "TEMPLATE_NAME: $TEMPLATE_NAME"

# Test CLI with a simple exercise
echo "Testing CLI..."
cd /home/ubuntu/LaunchRoo/Roo-Code/evals
pnpm cli run python hello_world

# Check the result
if [ $? -eq 0 ]; then
  echo "CLI test completed successfully!"
else
  echo "CLI test failed."
fi

# Don't kill Xvfb as it might be used by other processes
echo "Test completed"
EOL
chmod +x /home/ubuntu/LaunchRoo/ubuntu_roocode_implementation/test-roocode-cli.sh
echo "test-roocode-cli.sh created and made executable."

# Step 8: Create a README file
echo "Creating README file..."
cat > /home/ubuntu/LaunchRoo/ubuntu_roocode_implementation/README-roocode-cli.md << 'EOL'
# Roo Code CLI Setup for Ubuntu

This directory contains scripts to set up and run the Roo Code CLI with a virtual display on Ubuntu.

## Scripts

- `3_setup_roocode_cli.sh`: Set up the Roo Code CLI for Ubuntu
- `run-cli.sh`: Run Roo Code CLI with virtual display
- `test-roocode-cli.sh`: Test Roo Code CLI with a simple exercise

## Usage

1. Run the setup script:
   ```bash
   ./3_setup_roocode_cli.sh
   ```

2. Run Roo Code CLI:
   ```bash
   ./run-cli.sh python hello_world
   ```

3. Test the CLI:
   ```bash
   ./test-roocode-cli.sh
   ```

## Modifications

The following modifications have been made to make Roo Code work on Ubuntu:

1. VS Code launch command modified to use the virtual display
2. Added delay after VS Code launch to give it time to initialize
3. Increased IPC connection timeout to account for potentially slower startup on Ubuntu
4. Created wrapper scripts to set up the environment correctly

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
echo "  - ./test-roocode-cli.sh: Test Roo Code CLI with a simple exercise"
echo ""
echo "For more information, see README-roocode-cli.md"