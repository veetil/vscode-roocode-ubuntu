#!/bin/bash
# install-roocode-extension.sh - Install Roo Code extension for VS Code

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

# Install Roo Code extension
export DISPLAY=:1
echo "Installing Roo Code extension..."
code --install-extension roo-code.roo-code

# Verify installation
echo "Verifying Roo Code extension installation..."
if code --list-extensions | grep -q "roo-code.roo-code"; then
  echo "Roo Code extension is installed successfully!"
else
  echo "Error: Roo Code extension installation failed."
  exit 1
fi
