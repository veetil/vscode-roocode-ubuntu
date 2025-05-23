#!/bin/bash
# stop-xvfb.sh - Script to stop Xvfb virtual display

if [ -f /tmp/xvfb.pid ]; then
  echo "Stopping Xvfb process..."
  kill $(cat /tmp/xvfb.pid) 2>/dev/null || true
  rm /tmp/xvfb.pid
  echo "Xvfb stopped"
else
  echo "No Xvfb process found"
fi
