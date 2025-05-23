#!/bin/bash
# start-xvfb.sh - Script to start Xvfb virtual display

# Kill any existing Xvfb processes
if [ -f /tmp/xvfb.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb.pid) 2>/dev/null || true
  rm /tmp/xvfb.pid
fi

# Start Xvfb
export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
echo $! > /tmp/xvfb.pid
echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"

# Wait for Xvfb to initialize
sleep 2
