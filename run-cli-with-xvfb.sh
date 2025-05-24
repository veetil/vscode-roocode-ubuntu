#!/bin/bash
# run-cli-with-xvfb.sh - Run the CLI with virtual display

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up virtual display for Roo Code CLI..."

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

# Check if VS Code is installed
if ! command -v code &> /dev/null; then
  echo "VS Code is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install -y wget gpg apt-transport-https
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt-get update
  sudo apt-get install -y code
fi

# Install additional dependencies for VS Code rendering
if [ ! -f /tmp/.vscode_deps_installed ]; then
  echo "Installing additional dependencies for VS Code rendering..."
  sudo apt-get update
  
  # Try to install packages one by one to avoid failing if some are not available
  for pkg in libxrandr2 libxss1 libxcursor1 libxcomposite1 libxi6 libxtst6 libgbm1; do
    sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
  done
  
  # These packages might not be available in all Ubuntu versions
  for pkg in libgl1-mesa-glx libegl1-mesa libasound2; do
    sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
  done
  
  touch /tmp/.vscode_deps_installed
fi

# Clear VS Code cache if needed
if [ "$1" == "--clear-cache" ]; then
  echo "Clearing VS Code cache..."
  killall code 2>/dev/null || true
  rm -rf ~/.config/Code/Cache/* 2>/dev/null || true
  rm -rf ~/.config/Code/CachedData/* 2>/dev/null || true
  shift
fi

# Run the CLI command
echo "Running CLI command with virtual display: pnpm cli $@"
cd ~/LaunchRoo/Roo-Code/evals

# If ROO_TASK_TIMEOUT is set, display it
if [ -n "$ROO_TASK_TIMEOUT" ]; then
  echo "Using custom task timeout: $ROO_TASK_TIMEOUT milliseconds"
fi

# Print all environment variables for debugging
echo "Environment variables:"
env | grep ROO_

# Run the CLI command, passing through all environment variables
# Use env command to ensure ROO_TASK_TIMEOUT is passed to the CLI process
env ROO_TASK_TIMEOUT=$ROO_TASK_TIMEOUT pnpm cli "$@"

# Note: This script should be run from any directory, it will automatically
# change to the correct directory (~/LaunchRoo/Roo-Code/evals) to run the CLI command

# Optional: Take a screenshot to verify VS Code is rendering correctly
if [ "$1" == "--screenshot" ]; then
  echo "Taking a screenshot to verify..."
  FILENAME="screenshot-cli-$(date +%Y%m%d-%H%M%S).png"
  import -window root "$FILENAME"
  echo "Screenshot saved as $FILENAME"
fi

echo "CLI command completed."