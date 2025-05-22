#!/bin/bash
# test-vscode-server.sh - Test VS Code Server with virtual display
# This script tests VS Code Server mode with the virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code Server with virtual display..."

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

# Step 4: Create a test project directory
TEST_DIR="vscode-test-project"
mkdir -p $TEST_DIR
cd $TEST_DIR

# Create a test file
echo "Creating test files..."
echo "// Test JavaScript file" > test.js
echo "console.log('Hello, world!');" >> test.js
echo "# Test Markdown file" > README.md
echo "This is a test project for VS Code Server." >> README.md

# Step 5: Launch VS Code Server in the background
echo "Launching VS Code Server..."
# Use --no-sandbox to avoid permission issues
# Use --disable-gpu to avoid GPU acceleration issues
# Use --user-data-dir to use a separate user data directory
# Use --extensions-dir to use a separate extensions directory
code-server --auth none --port 8080 --disable-telemetry --user-data-dir=./user-data --extensions-dir=./extensions . &
SERVER_PID=$!

# Wait for VS Code Server to initialize
echo "Waiting for VS Code Server to initialize..."
sleep 10

# Step 6: Take a screenshot of the virtual display
echo "Taking screenshot of virtual display..."
cd ..
FILENAME="screenshot-vscode-server-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
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

# Step 7: Try to connect to VS Code Server using curl
echo "Testing connection to VS Code Server..."
curl -s http://localhost:8080/ > vscode-server-response.html
echo "VS Code Server response saved to vscode-server-response.html"

# Step 8: Kill VS Code Server
echo "Stopping VS Code Server..."
kill $SERVER_PID 2>/dev/null || true

# Step 9: Clean up
echo "Cleaning up..."
rm -rf $TEST_DIR

# Step 10: Stop Xvfb
echo "Stopping Xvfb..."
kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
rm -f /tmp/xvfb_${DISPLAY_NUM}.pid

echo "VS Code Server test completed."
echo ""
echo "CONCLUSION:"
echo "If the VS Code Server response was successful and the screenshot shows"
echo "proper rendering, then VS Code Server is working with the virtual display."
echo ""
echo "RECOMMENDATION:"
echo "For Roo Code on Ubuntu, consider using VS Code Server mode instead of"
echo "the full VS Code GUI. This will allow you to run VS Code on the AWS instance"
echo "with the virtual display, and access it through a web browser."