#!/bin/bash
# test-vscode-headless.sh - Test VS Code in headless mode with virtual display
# This script tests VS Code on the AWS instance without launching the local VS Code client

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code in headless mode with virtual display..."

# Step 1: Stop any running Xvfb instances
if [ -f /tmp/xvfb.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb.pid) 2>/dev/null || true
  rm /tmp/xvfb.pid
  echo "Xvfb stopped"
fi

# Step 2: Start Xvfb with improved configuration
echo "Starting Xvfb with improved configuration..."
export DISPLAY=:1
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
echo $! > /tmp/xvfb.pid
echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"

# Wait for Xvfb to initialize
sleep 3

# Step 3: Set environment variables to improve rendering
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1

# Step 4: Test VS Code CLI commands (these run on the server without launching GUI)
echo "Testing VS Code CLI commands..."
code --version
code --list-extensions

# Step 5: Create a simple test file
TEST_FILE="vscode-test-file.txt"
echo "Creating test file: $TEST_FILE"
echo "This is a test file for VS Code headless testing." > $TEST_FILE

# Step 6: Test VS Code in headless mode
echo "Testing VS Code in headless mode..."
code --help

# Step 7: Test VS Code extension management in headless mode
echo "Testing VS Code extension management..."
code --list-extensions

# Step 8: Take a screenshot of the virtual display
echo "Taking a screenshot of the virtual display..."
FILENAME="screenshot-vscode-headless-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Step 9: Check the size of the screenshot to verify it's not blank
FILE_SIZE=$(stat -c%s "$FILENAME")
echo "Screenshot file size: $FILE_SIZE bytes"

if [ $FILE_SIZE -lt 1000 ]; then
  echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
else
  echo "Screenshot file size looks good, rendering appears to be working."
fi

# Step 10: Clean up
rm -f $TEST_FILE

echo "VS Code headless test completed."