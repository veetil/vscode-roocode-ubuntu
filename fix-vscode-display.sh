#!/bin/bash
# fix-vscode-display.sh - Fix VS Code rendering in Xvfb virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Fixing VS Code rendering in virtual display..."

# Step 1: Stop any running Xvfb instances
if [ -f /tmp/xvfb.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb.pid) 2>/dev/null || true
  rm /tmp/xvfb.pid
  echo "Xvfb stopped"
fi

# Step 2: Start Xvfb with improved configuration for VS Code
echo "Starting Xvfb with improved configuration..."
export DISPLAY=:1
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
echo $! > /tmp/xvfb.pid
echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"

# Wait for Xvfb to initialize
sleep 3

# Step 3: Install additional dependencies that might be needed for VS Code rendering
echo "Installing additional dependencies for VS Code rendering..."
sudo apt-get update
sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libgbm1

# Step 4: Set environment variables that might help with rendering
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1

# Step 5: Test VS Code with the new configuration
echo "Testing VS Code with new configuration..."
code --version

# Step 6: Take a screenshot to verify
echo "Taking a screenshot to verify..."
FILENAME="screenshot-fixed-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

echo "Fix completed. Please check the new screenshot to verify if VS Code is rendering correctly."
echo "If VS Code is still not rendering correctly, try running VS Code with these flags:"
echo "code --disable-gpu --disable-software-rasterizer"