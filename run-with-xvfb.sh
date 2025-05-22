#!/bin/bash
# run-with-xvfb.sh - Run a command with the Xvfb virtual display

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

# Run the command with the virtual display
export DISPLAY=:1
echo "Running command with virtual display: $@"
"$@"
