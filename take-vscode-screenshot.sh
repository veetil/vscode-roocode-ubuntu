#!/bin/bash
# take-vscode-screenshot.sh - Take a screenshot of VSCode running in the virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up virtual display for VSCode screenshot..."

# Ensure Xvfb is running with optimized configuration
if ! pgrep -x Xvfb > /dev/null; then
  echo "Starting Xvfb..."
  export DISPLAY=:1
  Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
  echo $! > /tmp/xvfb.pid
  echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"
  sleep 3
fi

# Set environment variables for better rendering
export DISPLAY=:1
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1

# Check if imagemagick is installed
if ! command -v import >/dev/null 2>&1; then
  echo "Installing imagemagick..."
  sudo apt-get install -y imagemagick
fi

# Start VSCode in the background
echo "Starting VSCode in the virtual display..."
code --no-sandbox --disable-gpu &
VSCODE_PID=$!

# Wait for VSCode to start
echo "Waiting for VSCode to initialize (10 seconds)..."
sleep 10

# Take a screenshot
echo "Taking screenshot of VSCode..."
FILENAME="vscode-screenshot-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Kill VSCode
echo "Terminating VSCode..."
kill $VSCODE_PID

echo "Screenshot process completed."