#!/bin/bash
# test-vscode-improved.sh - Test VS Code with improved virtual display configuration

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing VS Code with improved virtual display configuration..."

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

# Step 4: Test VS Code with optimized settings
echo "Testing VS Code with optimized settings..."
code --version --disable-gpu --disable-software-rasterizer

# Step 5: Test VS Code extensions
echo "Listing VS Code extensions..."
code --list-extensions --disable-gpu --disable-software-rasterizer

# Step 6: Take a screenshot to verify
echo "Taking a screenshot to verify VS Code rendering..."
FILENAME="screenshot-vscode-test-$(date +%Y%m%d-%H%M%S).png"

# Launch VS Code with a simple file and capture screenshot after a delay
code --disable-gpu --disable-software-rasterizer README.md &
CODE_PID=$!

# Wait for VS Code to initialize
echo "Waiting for VS Code to initialize..."
sleep 10

# Take screenshot
echo "Taking screenshot..."
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Kill VS Code
echo "Closing VS Code..."
kill $CODE_PID 2>/dev/null || true

echo "VS Code test completed. Please check the screenshot to verify rendering."