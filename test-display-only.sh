#!/bin/bash
# test-display-only.sh - Test virtual display without launching VS Code GUI
# This script tests the virtual display using X11 tools without launching VS Code

set -e  # Exit immediately if a command exits with a non-zero status

echo "Testing virtual display without launching VS Code GUI..."

# Use display :99 to avoid conflicts
DISPLAY_NUM=99

# Step 1: Clean up any existing Xvfb processes for our display
if [ -f /tmp/xvfb_${DISPLAY_NUM}.pid ]; then
  echo "Stopping existing Xvfb process..."
  kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
  rm /tmp/xvfb_${DISPLAY_NUM}.pid
fi

# Remove any existing X locks for our display
if [ -f /tmp/.X${DISPLAY_NUM}-lock ]; then
  echo "Removing X lock file..."
  sudo rm -f /tmp/.X${DISPLAY_NUM}-lock
fi
if [ -S /tmp/.X11-unix/X${DISPLAY_NUM} ]; then
  echo "Removing X11 socket..."
  sudo rm -f /tmp/.X11-unix/X${DISPLAY_NUM}
fi

# Step 2: Start Xvfb with a different display number
echo "Starting Xvfb with display :${DISPLAY_NUM}..."
Xvfb :${DISPLAY_NUM} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
echo $! > /tmp/xvfb_${DISPLAY_NUM}.pid
echo "Started Xvfb with PID $(cat /tmp/xvfb_${DISPLAY_NUM}.pid)"

# Wait for Xvfb to initialize
sleep 3

# Step 3: Set environment variables
export DISPLAY=:${DISPLAY_NUM}
export LIBGL_ALWAYS_SOFTWARE=1

# Step 4: Install x11-apps if not already installed
if ! command -v xeyes &> /dev/null; then
  echo "Installing x11-apps for testing..."
  sudo apt-get update
  sudo apt-get install -y x11-apps
fi

# Step 5: Test with xeyes
echo "Testing with xeyes..."
xeyes &
XEYES_PID=$!
sleep 2

# Step 6: Take a screenshot of xeyes
echo "Taking screenshot of xeyes..."
FILENAME="screenshot-xeyes-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
import -window root "$FILENAME"
echo "Screenshot saved as $FILENAME"

# Check the size of the screenshot
FILE_SIZE=$(stat -c%s "$FILENAME")
echo "Screenshot file size: $FILE_SIZE bytes"

if [ $FILE_SIZE -lt 1000 ]; then
  echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
else
  echo "Screenshot file size looks good, rendering appears to be working."
fi

# Kill xeyes
kill $XEYES_PID 2>/dev/null || true

# Step 7: Create a simple X11 window with xmessage
echo "Testing with xmessage..."
if command -v xmessage &> /dev/null; then
  xmessage -center "Testing X11 rendering" &
  XMESSAGE_PID=$!
  sleep 2
  
  # Take a screenshot of xmessage
  echo "Taking screenshot of xmessage..."
  FILENAME="screenshot-xmessage-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
  import -window root "$FILENAME"
  echo "Screenshot saved as $FILENAME"
  
  # Check the size of the screenshot
  FILE_SIZE=$(stat -c%s "$FILENAME")
  echo "Screenshot file size: $FILE_SIZE bytes"
  
  if [ $FILE_SIZE -lt 1000 ]; then
    echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
  else
    echo "Screenshot file size looks good, rendering appears to be working."
  fi
  
  # Kill xmessage
  kill $XMESSAGE_PID 2>/dev/null || true
else
  echo "xmessage not found, skipping this test"
fi

# Step 8: Create a simple X window with xterm if available
if command -v xterm &> /dev/null; then
  echo "Testing with xterm..."
  xterm -e "echo 'Testing xterm rendering'; sleep 5" &
  XTERM_PID=$!
  sleep 2
  
  # Take a screenshot of xterm
  echo "Taking screenshot of xterm..."
  FILENAME="screenshot-xterm-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
  import -window root "$FILENAME"
  echo "Screenshot saved as $FILENAME"
  
  # Check the size of the screenshot
  FILE_SIZE=$(stat -c%s "$FILENAME")
  echo "Screenshot file size: $FILE_SIZE bytes"
  
  if [ $FILE_SIZE -lt 1000 ]; then
    echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
  else
    echo "Screenshot file size looks good, rendering appears to be working."
  fi
  
  # Kill xterm
  kill $XTERM_PID 2>/dev/null || true
else
  echo "xterm not found, skipping this test"
fi

# Step 9: Test with xclock if available
if command -v xclock &> /dev/null; then
  echo "Testing with xclock..."
  xclock &
  XCLOCK_PID=$!
  sleep 2
  
  # Take a screenshot of xclock
  echo "Taking screenshot of xclock..."
  FILENAME="screenshot-xclock-display${DISPLAY_NUM}-$(date +%Y%m%d-%H%M%S).png"
  import -window root "$FILENAME"
  echo "Screenshot saved as $FILENAME"
  
  # Check the size of the screenshot
  FILE_SIZE=$(stat -c%s "$FILENAME")
  echo "Screenshot file size: $FILE_SIZE bytes"
  
  if [ $FILE_SIZE -lt 1000 ]; then
    echo "WARNING: Screenshot file size is very small, it might be blank or have rendering issues."
  else
    echo "Screenshot file size looks good, rendering appears to be working."
  fi
  
  # Kill xclock
  kill $XCLOCK_PID 2>/dev/null || true
else
  echo "xclock not found, skipping this test"
fi

# Step 10: Stop Xvfb
echo "Stopping Xvfb..."
kill $(cat /tmp/xvfb_${DISPLAY_NUM}.pid) 2>/dev/null || true
rm -f /tmp/xvfb_${DISPLAY_NUM}.pid

echo "Virtual display test completed."
echo ""
echo "CONCLUSION:"
echo "If the screenshots of X11 applications (xeyes, xmessage, xterm, xclock) show"
echo "proper rendering with file sizes > 1000 bytes, then the virtual display is working correctly."
echo "However, VS Code is still having issues with the virtual display."
echo ""
echo "RECOMMENDATION:"
echo "1. Use a different approach for automating VS Code with Roo Code on Ubuntu:"
echo "   - Use VS Code's Remote SSH extension (which you're already using)"
echo "   - Use VS Code's CLI features that don't require a GUI"
echo "   - Consider using VS Code Server instead of the full VS Code GUI"
echo "2. For testing purposes, use simpler X11 applications like xeyes, xclock, etc."
echo "   to verify that the virtual display is working correctly."