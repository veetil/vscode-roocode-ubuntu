#!/bin/bash
# setup-xvfb-service.sh - Set up Xvfb as a systemd service

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Xvfb as a systemd service..."

# Install required packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y xvfb x11-utils x11-apps imagemagick

# Create systemd service file
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/xvfb.service > /dev/null << EOL
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
echo "Enabling and starting Xvfb service..."
sudo systemctl daemon-reload
sudo systemctl enable xvfb.service
sudo systemctl start xvfb.service

# Check if service is running
echo "Checking if Xvfb service is running..."
if systemctl is-active --quiet xvfb.service; then
  echo "Xvfb service is running."
else
  echo "Error: Xvfb service failed to start."
  exit 1
fi

# Install additional dependencies for VS Code rendering
echo "Installing additional dependencies for VS Code rendering..."

# Try to install packages one by one to avoid failing if some are not available
for pkg in libxrandr2 libxss1 libxcursor1 libxcomposite1 libxi6 libxtst6 libgbm1; do
  sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done

# These packages might not be available in all Ubuntu versions
for pkg in libgl1-mesa-glx libegl1-mesa libasound2; do
  sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done

# Create a script to check if the display is working
echo "Creating display test script..."
cat > test-display.sh << EOL
#!/bin/bash
export DISPLAY=:1
xdpyinfo | grep "dimensions"
EOL
chmod +x test-display.sh

# Test the display
echo "Testing the display..."
export DISPLAY=:1
if xdpyinfo | grep "dimensions"; then
  echo "Display is working correctly."
else
  echo "Error: Display is not working correctly."
  exit 1
fi

echo "Xvfb service has been set up successfully."
echo "You can now use the virtual display by setting DISPLAY=:1"
echo "To test the display, run: ./test-display.sh"