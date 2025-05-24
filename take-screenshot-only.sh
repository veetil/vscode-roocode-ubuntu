#!/bin/bash
# take-screenshot-only.sh - Take a screenshot of the current virtual display

# Set environment variables for the virtual display
export DISPLAY=:1

# Check if imagemagick is installed
if ! command -v import >/dev/null 2>&1; then
  echo "Installing imagemagick..."
  sudo apt-get install -y imagemagick
fi

# Take a screenshot
echo "Taking screenshot of the current virtual display..."
FILENAME="xvfb-screenshot-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"