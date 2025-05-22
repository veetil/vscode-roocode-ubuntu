#!/bin/bash
# run-with-xvfb-improved.sh - Run a command with the improved Xvfb virtual display configuration

# Ensure Xvfb is running
if ! pgrep -x Xvfb > /dev/null; then
  echo "Starting Xvfb..."
  export DISPLAY=:1
  # Improved configuration for better VS Code rendering
  Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
  echo $! > /tmp/xvfb.pid
  echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"
  # Give Xvfb more time to initialize
  sleep 3
fi

# Set environment variables to improve rendering
export DISPLAY=:1
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1

# Special handling for VS Code
if [[ "$1" == "code" || "$1" == *"/code" ]]; then
  echo "Running VS Code with optimized settings..."
  # Add flags to improve VS Code rendering in virtual display
  "$@" --disable-gpu --disable-software-rasterizer
else
  # Run the command with the virtual display
  echo "Running command with virtual display: $@"
  "$@"
fi