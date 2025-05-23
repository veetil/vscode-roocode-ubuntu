#!/bin/bash
# fix-xvfb-lock.sh - Fix Xvfb lock issues and test VS Code rendering

set -e  # Exit immediately if a command exits with a non-zero status

echo "Fixing Xvfb lock issues and testing VS Code rendering..."

# Step 1: Clean up any existing Xvfb processes and locks
echo "Cleaning up existing Xvfb processes and locks..."
if [ -f /tmp/xvfb.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb.pid) 2>/dev/null || true
  rm /tmp/xvfb.pid
fi

# Remove any existing X locks for display :1
if [ -f /tmp/.X1-lock ]; then
  echo "Removing X lock file..."
  sudo rm -f /tmp/.X1-lock
fi
if [ -d /tmp/.X11-unix/X1 ]; then
  echo "Removing X11 socket..."
  sudo rm -f /tmp/.X11-unix/X1
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

# Step 4: Install additional dependencies that might be needed for VS Code rendering
echo "Installing additional dependencies for VS Code rendering..."
sudo apt-get update
sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libgbm1

# Step 5: Test with a simple X application (xeyes if available)
if command -v xeyes >/dev/null 2>&1; then
  echo "Testing with xeyes..."
  xeyes &
  XEYES_PID=$!
  sleep 2
  
  # Take a screenshot of xeyes
  echo "Taking screenshot of xeyes..."
  FILENAME="screenshot-xeyes-$(date +%Y%m%d-%H%M%S).png"
  import -window root "$FILENAME"
  echo "Screenshot saved as $FILENAME"
  
  # Kill xeyes
  kill $XEYES_PID 2>/dev/null || true
fi

# Step 6: Test with VS Code in a way that doesn't launch the GUI client
echo "Testing VS Code CLI..."
code --version

# Step 7: Try to launch a minimal VS Code window for testing
echo "Attempting to launch a minimal VS Code window..."
# Create a test file
TEST_FILE="vscode-test-file.txt"
echo "This is a test file for VS Code." > $TEST_FILE

# Try to launch VS Code with the test file in a way that doesn't connect to the client
code --disable-gpu --disable-extensions "$TEST_FILE" &
CODE_PID=$!

# Wait for VS Code to initialize
sleep 5

# Take a screenshot
echo "Taking screenshot of VS Code..."
FILENAME="screenshot-vscode-fixed-$(date +%Y%m%d-%H%M%S).png"
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

echo "Xvfb lock fix and VS Code rendering test completed."