#!/bin/bash
# test-cli-with-xvfb.sh - Test the CLI with virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing Roo Code CLI with virtual display..."

# Check if Xvfb is installed
if ! command -v Xvfb &> /dev/null; then
  echo "Xvfb is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install -y xvfb x11-utils x11-apps imagemagick
fi

# Install additional dependencies for VS Code rendering if needed
echo "Checking for additional dependencies for VS Code rendering..."
for pkg in libxrandr2 libxss1 libxcursor1 libxcomposite1 libxi6 libxtst6 libgbm1; do
  dpkg -l | grep -q $pkg || sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done

# Check if VS Code is installed
if ! command -v code &> /dev/null; then
  echo "VS Code is not installed. Please install VS Code first."
  exit 1
fi

# Check if the Roo Code repository exists
if [ ! -d ~/LaunchRoo/Roo-Code ]; then
  echo "Roo Code repository not found at ~/LaunchRoo/Roo-Code"
  exit 1
fi

# Check if the evals directory exists
if [ ! -d ~/LaunchRoo/Roo-Code/evals ]; then
  echo "Evals directory not found at ~/LaunchRoo/Roo-Code/evals"
  exit 1
fi

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
  echo "pnpm is not installed. Please install pnpm first."
  exit 1
fi

# Kill any existing Xvfb processes
echo "Killing any existing Xvfb processes..."
pkill -f Xvfb || true
sleep 2

# Start Xvfb with optimized settings
echo "Starting Xvfb..."
export DISPLAY=:1
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
XVFB_PID=$!
echo "Started Xvfb with PID $XVFB_PID"
sleep 3

# Check if Xvfb is running
if ! ps -p $XVFB_PID > /dev/null; then
  echo "Error: Xvfb failed to start."
  exit 1
fi

# Test the display
echo "Testing the display..."
if xdpyinfo | grep "dimensions"; then
  echo "Display is working correctly."
else
  echo "Error: Display is not working correctly."
  kill $XVFB_PID
  exit 1
fi

# Set environment variables for better rendering
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1
export ELECTRON_ENABLE_SECURITY_WARNINGS=false

# Clear VS Code cache
echo "Clearing VS Code cache..."
killall code 2>/dev/null || true
rm -rf ~/.config/Code/Cache/* 2>/dev/null || true
rm -rf ~/.config/Code/CachedData/* 2>/dev/null || true
sleep 2

# Run the CLI command with timing
echo "Running CLI command: pnpm cli python grep"
cd ~/LaunchRoo/Roo-Code/evals
time pnpm cli python grep &
CLI_PID=$!

# Take a screenshot after 10 seconds
echo "Waiting 10 seconds for VS Code to start..."
sleep 10
FILENAME="screenshot-cli-test-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Wait for the CLI command to complete or timeout after 60 seconds
echo "Waiting for CLI command to complete (timeout: 60 seconds)..."
timeout 60s tail --pid=$CLI_PID -f /dev/null
CLI_EXIT_CODE=$?

# Check the exit code
if [ $CLI_EXIT_CODE -eq 0 ]; then
  echo "CLI command completed successfully."
else
  echo "CLI command failed with exit code $CLI_EXIT_CODE."
fi

# Take a final screenshot
FILENAME="screenshot-cli-final-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Final screenshot saved as $FILENAME"

# Kill Xvfb
echo "Killing Xvfb..."
kill $XVFB_PID

echo "Test completed."