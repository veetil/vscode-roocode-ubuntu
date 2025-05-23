#!/bin/bash
# 1_setup_virtual_display.sh
# This script sets up a virtual display environment using Xvfb on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up virtual display environment for Roo Code on Ubuntu..."

# Step 1: Install Xvfb and X11 utilities
echo "Installing Xvfb and X11 utilities..."
sudo apt-get update
sudo apt-get install -y xvfb x11-utils

# Step 2: Create a script to start Xvfb
echo "Creating Xvfb startup script..."
cat > start-xvfb.sh << 'EOL'
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
EOL

chmod +x start-xvfb.sh

# Step 3: Create a script to stop Xvfb
echo "Creating Xvfb stop script..."
cat > stop-xvfb.sh << 'EOL'
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
EOL

chmod +x stop-xvfb.sh

# Step 4: Test the virtual display
echo "Testing virtual display..."
./start-xvfb.sh

# Verify that the display is working
if xdpyinfo -display :1 >/dev/null 2>&1; then
  echo "Virtual display is working correctly!"
  DIMENSIONS=$(xdpyinfo -display :1 | grep "dimensions" | awk '{print $2}')
  echo "Display dimensions: $DIMENSIONS"
else
  echo "Error: Virtual display is not working correctly."
  exit 1
fi

# Step 5: Create a systemd service for Xvfb (optional)
echo "Creating systemd service for Xvfb..."
cat > xvfb.service << 'EOL'
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset
ExecStop=/bin/kill -15 $MAINPID
Type=simple
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

echo "Would you like to install the Xvfb systemd service? (y/n)"
read -r install_service

if [ "$install_service" = "y" ]; then
  sudo mv xvfb.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable xvfb.service
  sudo systemctl start xvfb.service
  echo "Xvfb service installed and started"
else
  echo "Skipping systemd service installation"
  rm xvfb.service
fi

# Step 6: Create a script to run commands with the virtual display
echo "Creating a helper script to run commands with the virtual display..."
cat > run-with-xvfb.sh << 'EOL'
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
EOL

chmod +x run-with-xvfb.sh

# Step 7: Test the helper script with a simple command
echo "Testing the helper script..."
if command -v xeyes >/dev/null 2>&1; then
  echo "Testing with xeyes (will run in background)..."
  ./run-with-xvfb.sh xeyes &
  XEYES_PID=$!
  sleep 2
  kill $XEYES_PID 2>/dev/null || true
else
  echo "xeyes not found, skipping this test"
fi

# Step 8: Create a script to take screenshots of the virtual display
echo "Creating a script to take screenshots of the virtual display..."
cat > take-screenshot.sh << 'EOL'
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
EOL

chmod +x take-screenshot.sh

# Step 9: Create a README file
echo "Creating README file..."
cat > README-virtual-display.md << 'EOL'
# Virtual Display Setup for Roo Code on Ubuntu

This directory contains scripts to set up and manage a virtual display environment using Xvfb on Ubuntu.

## Scripts

- `start-xvfb.sh`: Start the Xvfb virtual display
- `stop-xvfb.sh`: Stop the Xvfb virtual display
- `run-with-xvfb.sh`: Run a command with the virtual display
- `take-screenshot.sh`: Take a screenshot of the virtual display

## Usage

1. Start the virtual display:
   ```bash
   ./start-xvfb.sh
   ```

2. Run a command with the virtual display:
   ```bash
   ./run-with-xvfb.sh code --version
   ```

3. Take a screenshot of the virtual display:
   ```bash
   ./take-screenshot.sh
   ```

4. Stop the virtual display:
   ```bash
   ./stop-xvfb.sh
   ```

## Systemd Service

If you installed the systemd service, you can manage Xvfb using:

```bash
sudo systemctl start xvfb.service
sudo systemctl stop xvfb.service
sudo systemctl status xvfb.service
```

## Troubleshooting

If you encounter issues with the virtual display:

1. Check if Xvfb is running:
   ```bash
   ps aux | grep Xvfb
   ```

2. Verify the DISPLAY environment variable:
   ```bash
   echo $DISPLAY
   ```

3. Test the display with xdpyinfo:
   ```bash
   export DISPLAY=:1
   xdpyinfo | grep "dimensions"
   ```

4. Check Xvfb logs:
   ```bash
   sudo journalctl -u xvfb.service
   ```
EOL

echo "Virtual display environment setup completed successfully!"
echo "You can now use the following scripts:"
echo "  - ./start-xvfb.sh: Start the virtual display"
echo "  - ./stop-xvfb.sh: Stop the virtual display"
echo "  - ./run-with-xvfb.sh: Run a command with the virtual display"
echo "  - ./take-screenshot.sh: Take a screenshot of the virtual display"
echo ""
echo "For more information, see README-virtual-display.md"