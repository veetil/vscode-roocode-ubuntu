#!/bin/bash
# test-vscode-direct.sh - Test VS Code directly with virtual display
# This script uses a direct approach to test VS Code with the virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code directly with virtual display..."

# Use display :99 to avoid conflicts
DISPLAY_NUM=99

# Step 1: Clean up any existing Xvfb processes for our display
if [ -f /tmp/xvfb_${DISPLAY_NUM}.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
  rm /tmp/xvfb_${DISPLAY_NUM}.pid
fi

# Remove any existing X locks for our display
if [ -f /tmp/.X${DISPLAY_NUM}-lock ]; then
  echo "Removing X lock file..."
  sudo rm -f /tmp/.X${DISPLAY_NUM}-lock
fi
if [ -S /tmp/.X11-unix/X${DISPLAY_NUM} ]; then
  echo "Removing X11 socket..."
  sudo rm -f /tmp/.X11-unix/X${DISPLAY_NUM}
fi

# Step 2: Start Xvfb with a different display number
echo "Starting Xvfb with display :${DISPLAY_NUM}..."
Xvfb :${DISPLAY_NUM} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
echo $! > /tmp/xvfb_${DISPLAY_NUM}.pid
echo "Started Xvfb with PID $(cat /tmp/xvfb_${DISPLAY_NUM}.pid)"

# Wait for Xvfb to initialize
sleep 3

# Step 3: Set environment variables
export DISPLAY=:${DISPLAY_NUM}
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1
export ELECTRON_NO_ATTACH_CONSOLE=1
export ELECTRON_ENABLE_LOGGING=1
export DONT_PROMPT_WSL_INSTALL=1

# Step 4: Create a test project directory
TEST_DIR="vscode-direct-test"
mkdir -p $TEST_DIR
cd $TEST_DIR

# Create a test file
echo "Creating test files..."
echo "// Test JavaScript file" > test.js
echo "console.log('Hello, world!');" >> test.js
echo "# Test Markdown file" > README.md
echo "This is a test project for VS Code direct testing." >> README.md

# Step 5: Find the VS Code executable path
VSCODE_PATH=$(which code)
echo "VS Code path: $VSCODE_PATH"

# Step 6: Try to find the actual Electron executable
if [ -f "$VSCODE_PATH" ]; then
  echo "Examining VS Code executable..."
  file $VSCODE_PATH
  
  # If it's a symlink, follow it
  if [ -L "$VSCODE_PATH" ]; then
    VSCODE_REAL_PATH=$(readlink -f $VSCODE_PATH)
    echo "VS Code real path: $VSCODE_REAL_PATH"
  fi
fi

# Step 7: Try to find the VS Code installation directory
VSCODE_INSTALL_DIR=$(dirname $(readlink -f $(which code)))
echo "VS Code installation directory: $VSCODE_INSTALL_DIR"

# Step 8: Try to find the VS Code Electron executable
if [ -d "$VSCODE_INSTALL_DIR" ]; then
  echo "Looking for VS Code Electron executable..."
  find $VSCODE_INSTALL_DIR -name "electron" -type f 2>/dev/null || echo "Electron executable not found"
fi

# Step 9: Try to launch VS Code with special flags
echo "Launching VS Code directly..."
# Create a wrapper script to launch VS Code with the correct environment
cat > launch-vscode.sh << 'EOL'
#!/bin/bash
export DISPLAY=:99
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1
export ELECTRON_NO_ATTACH_CONSOLE=1
export ELECTRON_ENABLE_LOGGING=1
export DONT_PROMPT_WSL_INSTALL=1

# Launch VS Code with special flags
code --no-sandbox --disable-gpu --verbose --log=debug --disable-telemetry --disable-updates --disable-crash-reporter --disable-workspace-trust --skip-welcome --skip-release-notes "$@"
EOL

chmod +x launch-vscode.sh

# Launch VS Code with the wrapper script
./launch-vscode.sh . &
VSCODE_PID=$!

# Wait for VS Code to initialize
echo "Waiting for VS Code to initialize..."
sleep 10

# Step 10: Take a screenshot of the virtual display
echo "Taking screenshot of VS Code..."
cd ..
FILENAME="screenshot-vscode-direct-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Check the size of the screenshot
FILE_SIZE=$(stat -c%s "$FILENAME")
echo "Screenshot file size: $FILE_SIZE bytes"

if [ $FILE_SIZE -lt 1000 ]; then
  echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
else
  echo "Screenshot file size looks good, rendering appears to be working."
fi

# Step 11: Kill VS Code
echo "Stopping VS Code..."
kill $VSCODE_PID 2>/dev/null || true

# Step 12: Clean up
echo "Cleaning up..."
rm -rf $TEST_DIR

# Step 13: Stop Xvfb
echo "Stopping Xvfb..."
kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
rm -f /tmp/xvfb_${DISPLAY_NUM}.pid

echo "VS Code direct test completed."
echo ""
echo "CONCLUSION:"
echo "If the screenshot shows VS Code running, then the virtual display is working with VS Code."
echo "If the screenshot is blank or very small, then VS Code is not rendering properly with the virtual display."
echo ""
echo "RECOMMENDATION:"
echo "If VS Code is not rendering properly, try using VS Code Server mode instead,"
echo "or use VS Code's CLI features that don't require a GUI."