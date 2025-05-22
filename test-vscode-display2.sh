#!/bin/bash
# test-vscode-display2.sh - Test VS Code with a different virtual display number

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code with a different virtual display number..."

# Use display :99 instead of :1 to avoid conflicts
DISPLAY_NUM=99

# Step 1: Clean up any existing Xvfb processes for our display
if [ -f /tmp/xvfb_${DISPLAY_NUM}.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
  rm /tmp/xvfb_${DISPLAY_NUM}.pid
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

# Step 4: Install xeyes for testing if not already installed
if ! command -v xeyes &> /dev/null; then
  echo "Installing x11-apps for testing..."
  sudo apt-get update
  sudo apt-get install -y x11-apps
fi

# Step 5: Test with xeyes
echo "Testing with xeyes..."
xeyes &
XEYES_PID=$!
sleep 2

# Step 6: Take a screenshot of xeyes
echo "Taking screenshot of xeyes..."
FILENAME="screenshot-xeyes-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
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

# Kill xeyes
kill $XEYES_PID 2>/dev/null || true

# Step 7: Test VS Code CLI
echo "Testing VS Code CLI..."
code --version

# Step 8: Create a test file
TEST_FILE="vscode-test-file.txt"
echo "Creating test file: $TEST_FILE"
echo "This is a test file for VS Code display testing." > $TEST_FILE

# Step 9: Try to launch VS Code with the test file
echo "Attempting to launch VS Code with test file..."
code --disable-gpu "$TEST_FILE" &
CODE_PID=$!
sleep 5

# Step 10: Take a screenshot of VS Code
echo "Taking screenshot of VS Code..."
FILENAME="screenshot-vscode-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
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

# Kill VS Code
kill $CODE_PID 2>/dev/null || true

# Clean up
rm -f $TEST_FILE

# Step 11: Stop Xvfb
echo "Stopping Xvfb..."
kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
rm -f /tmp/xvfb_${DISPLAY_NUM}.pid

echo "VS Code display test completed."