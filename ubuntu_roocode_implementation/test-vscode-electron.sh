#!/bin/bash
# test-vscode-electron.sh - Test VS Code Electron app with virtual display
# This script tests VS Code Electron app directly with the virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code Electron app with virtual display..."

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

# Step 4: Create a test project directory
TEST_DIR="vscode-electron-test"
mkdir -p $TEST_DIR
cd $TEST_DIR

# Create a test file
echo "Creating test files..."
echo "// Test JavaScript file" > test.js
echo "console.log('Hello, world!');" >> test.js
echo "# Test Markdown file" > README.md
echo "This is a test project for VS Code Electron." >> README.md

# Step 5: Find the VS Code Electron executable
VSCODE_PATH=$(which code)
echo "VS Code path: $VSCODE_PATH"

# Step 6: Launch VS Code with special flags to prevent remote SSH
echo "Launching VS Code Electron app..."
# Use --no-sandbox to avoid permission issues
# Use --disable-gpu to avoid GPU acceleration issues
# Use --user-data-dir to use a separate user data directory
# Use --extensions-dir to use a separate extensions directory
# Use --disable-telemetry to disable telemetry
# Use --verbose to get more logs
# Use --log=debug to get debug logs
# Use --new-window to force a new window
# Use --disable-workspace-trust to disable workspace trust
# Use --skip-welcome to skip the welcome page
# Use --skip-release-notes to skip the release notes
# Use --disable-updates to disable updates
# Use --disable-crash-reporter to disable crash reporter
$VSCODE_PATH --no-sandbox --disable-gpu --user-data-dir=./user-data --extensions-dir=./extensions --disable-telemetry --verbose --log=debug --new-window --disable-workspace-trust --skip-welcome --skip-release-notes --disable-updates --disable-crash-reporter . &
VSCODE_PID=$!

# Wait for VS Code to initialize
echo "Waiting for VS Code to initialize..."
sleep 10

# Step 7: Take a screenshot of the virtual display
echo "Taking screenshot of VS Code Electron app..."
cd ..
FILENAME="screenshot-vscode-electron-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
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

# Step 8: Kill VS Code
echo "Stopping VS Code Electron app..."
kill $VSCODE_PID 2>/dev/null || true

# Step 9: Clean up
echo "Cleaning up..."
rm -rf $TEST_DIR

# Step 10: Stop Xvfb
echo "Stopping Xvfb..."
kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
rm -f /tmp/xvfb_${DISPLAY_NUM}.pid

echo "VS Code Electron app test completed."