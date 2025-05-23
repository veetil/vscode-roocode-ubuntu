#!/bin/bash
# take-screenshot.sh - Take a screenshot of the virtual display

# Ensure Xvfb is running
if ! pgrep -x Xvfb > /dev/null; then
  echo "Xvfb is not running. Please start it first."
  exit 1
fi

# Check if imagemagick is installed
if ! command -v import >/dev/null 2>&1; then
  echo "Installing imagemagick..."
  sudo apt-get install -y imagemagick
fi

# Take a screenshot
export DISPLAY=:1
FILENAME="screenshot-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"
