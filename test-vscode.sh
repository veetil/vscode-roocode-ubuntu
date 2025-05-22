#!/bin/bash
# test-vscode.sh - Test VS Code with virtual display

# Ensure Xvfb is running
if ! pgrep -x Xvfb > /dev/null; then
  echo "Starting Xvfb..."
  export DISPLAY=:1
  Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
  echo $! > /tmp/xvfb.pid
  echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"
  # Give Xvfb some time to initialize
  sleep 2
fi

# Test VS Code
export DISPLAY=:1
echo "Testing VS Code..."
code --version

# Test VS Code extensions
echo "Listing VS Code extensions..."
code --list-extensions

# Test VS Code CLI
echo "Testing VS Code CLI..."
code --help
