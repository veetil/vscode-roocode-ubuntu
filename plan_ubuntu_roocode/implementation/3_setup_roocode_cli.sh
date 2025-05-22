#!/bin/bash
# 3_setup_roocode_cli.sh
# This script sets up the Roo Code repository and modifies the CLI to work with the virtual display on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Roo Code repository and modifying CLI for Ubuntu..."

# Step 1: Clone the Roo Code repository
echo "Cloning Roo Code repository..."
REPO_URL=${1:-"https://github.com/your-repo/Roo-Code.git"}
REPO_DIR="Roo-Code"

if [ -d "$REPO_DIR" ]; then
  echo "Repository directory already exists. Updating..."
  cd "$REPO_DIR"
  git pull
  cd ..
else
  git clone "$REPO_URL" "$REPO_DIR"
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

# Step 5: Create environment variables file
echo "Creating environment variables file..."
if [ ! -f ".env" ]; then
  cat > .env << 'EOL'
# Remote Implementation Configuration
REMOTE_IMPLEMENTATION_SIMULATION_MODE=false
FALLBACK_TO_SIMULATION=false
NEXT_PUBLIC_USE_POLLING=true

# API Keys
OPENAI_API_KEY='your_openai_api_key'
# Replace with your actual API key

# Ubuntu-specific configuration
ROO_CODE_IPC_TIMEOUT=10000
EOL
  echo ".env file created. Please update it with your actual API keys."
else
  echo ".env file already exists. Please ensure it contains the necessary API keys."
fi

# Step 6: Create export script
echo "Creating export script..."
if [ ! -f "export-env.sh" ]; then
  cat > export-env.sh << 'EOL'
#!/bin/bash

# Load .env file and export variables
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines
  if [[ $line =~ ^[[:space:]]*$ || $line =~ ^[[:space:]]*# ]]; then
    continue
  fi
  
  # Remove leading/trailing whitespace
  line=$(echo "$line" | xargs)
  
  # Export the variable
  export "$line"
  
  # Extract variable name for display
  var_name=$(echo "$line" | cut -d= -f1)
  echo "Exported: $var_name"
done < .env

# Verify a few key variables (optional)
echo -e "\nVerification:"
echo "OPENAI_API_KEY: ${OPENAI_API_KEY:0:5}..."
echo "ROO_CODE_IPC_TIMEOUT: $ROO_CODE_IPC_TIMEOUT"
EOL
  chmod +x export-env.sh
  echo "export-env.sh created and made executable."
else
  echo "export-env.sh already exists."
fi

# Step 7: Create CLI wrapper script
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

# Export environment variables
source ./export-env.sh

# Set additional environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000

# Run the CLI
cd evals
pnpm cli "$@"
EOL
chmod +x run-cli.sh
echo "run-cli.sh created and made executable."

# Step 8: Create a test script
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

# Export environment variables
source ./export-env.sh

# Set additional environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000

# Test CLI with a simple exercise
echo "Testing CLI..."
cd evals
pnpm cli python hello_world

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

# Step 9: Create a README file
echo "Creating README file..."
cat > README-roocode-cli.md << 'EOL'
# Roo Code CLI Setup for Ubuntu

This directory contains the Roo Code repository with modifications to make it work on Ubuntu with a virtual display.

## Scripts

- `export-env.sh`: Export environment variables from .env file
- `run-cli.sh`: Run Roo Code CLI with virtual display
- `test-cli.sh`: Test Roo Code CLI with a simple exercise

## Usage

1. Update the `.env` file with your API keys:
   ```bash
   nano .env
   ```

2. Export environment variables:
   ```bash
   source ./export-env.sh
   ```

3. Run Roo Code CLI:
   ```bash
   ./run-cli.sh python hello_world
   ```

4. Test the CLI:
   ```bash
   ./test-cli.sh
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
echo "  - ./export-env.sh: Export environment variables from .env file"
echo "  - ./run-cli.sh: Run Roo Code CLI with virtual display"
echo "  - ./test-cli.sh: Test Roo Code CLI with a simple exercise"
echo ""
echo "For more information, see README-roocode-cli.md"
echo ""
echo "IMPORTANT: Please update the .env file with your actual API keys before running the CLI."