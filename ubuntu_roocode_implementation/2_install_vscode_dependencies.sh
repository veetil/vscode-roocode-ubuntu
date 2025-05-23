#!/bin/bash
# 2_install_vscode_dependencies.sh
# This script installs VS Code and all required dependencies for Roo Code on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Installing VS Code and dependencies for Roo Code on Ubuntu..."

# Step 1: Install prerequisites
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y wget gpg apt-transport-https software-properties-common curl git build-essential

# Step 2: Install Node.js
echo "Installing Node.js..."
NODE_VERSION="18"
if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt $NODE_VERSION ]]; then
    echo "Installing Node.js $NODE_VERSION..."
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js $(node -v) is already installed"
fi

# Verify Node.js installation
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Step 3: Install pnpm
echo "Installing pnpm..."
if ! command -v pnpm &> /dev/null; then
    sudo npm install -g pnpm
else
    echo "pnpm $(pnpm -v) is already installed"
fi

# Verify pnpm installation
echo "pnpm version: $(pnpm -v)"

# Step 4: Install VS Code
echo "Installing VS Code..."
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get update
    sudo apt-get install -y code
    rm packages.microsoft.gpg
else
    echo "VS Code $(code --version | head -n 1) is already installed"
fi

# Verify VS Code installation
echo "VS Code version: $(code --version | head -n 1)"

# Step 5: Install Python and related tools
echo "Installing Python and related tools..."
sudo apt-get install -y python3 python3-pip python3-venv

# Install uv (Python package installer)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    pip install uv
else
    echo "uv $(uv --version) is already installed"
fi

# Verify Python installation
echo "Python version: $(python3 --version)"
if command -v uv &> /dev/null; then
    echo "uv version: $(uv --version)"
fi

# Step 6: Install additional dependencies for VS Code
echo "Installing additional dependencies for VS Code..."
# Fix for libasound2 virtual package issue
sudo apt-get install -y libx11-xcb1 libxcb-dri3-0 libdrm2 libgbm1 libasound2t64 libxkbfile1 libsecret-1-0

# Step 7: Create a script to test VS Code with virtual display
echo "Creating a script to test VS Code with virtual display..."
cat > test-vscode.sh << 'EOL'
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
EOL

chmod +x test-vscode.sh

# Step 8: Create a script to install Roo Code extension
echo "Creating a script to install Roo Code extension..."
cat > install-roocode-extension.sh << 'EOL'
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
EOL

chmod +x install-roocode-extension.sh

# Step 9: Create a README file
echo "Creating README file..."
cat > README-vscode-setup.md << 'EOL'
# VS Code Setup for Roo Code on Ubuntu

This directory contains scripts to install and test VS Code and its dependencies for Roo Code on Ubuntu.

## Scripts

- `test-vscode.sh`: Test VS Code with virtual display
- `install-roocode-extension.sh`: Install Roo Code extension for VS Code

## Usage

1. Test VS Code with virtual display:
   ```bash
   ./test-vscode.sh
   ```

2. Install Roo Code extension:
   ```bash
   ./install-roocode-extension.sh
   ```

## Installed Components

- Node.js 18.x
- pnpm
- VS Code
- Python 3 and uv
- Additional dependencies for VS Code

## Troubleshooting

If you encounter issues with VS Code:

1. Check if VS Code is installed correctly:
   ```bash
   which code
   code --version
   ```

2. Verify that VS Code can run in the virtual display:
   ```bash
   export DISPLAY=:1
   code --version
   ```

3. Check VS Code logs:
   ```bash
   cat ~/.config/Code/logs/main.log
   ```

4. If VS Code fails to start, try with verbose logging:
   ```bash
   export DISPLAY=:1
   code --verbose --log debug
   ```

5. Ensure all dependencies are installed:
   ```bash
   sudo apt-get install -y libx11-xcb1 libxcb-dri3-0 libdrm2 libgbm1 libasound2t64 libxkbfile1 libsecret-1-0
   ```
EOL

# Step 10: Test VS Code with virtual display
echo "Testing VS Code with virtual display..."
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

echo "Testing VS Code..."
export DISPLAY=:1
if code --version > /dev/null 2>&1; then
  echo "VS Code is working correctly with the virtual display!"
else
  echo "Warning: VS Code test failed. Please check the installation and virtual display setup."
fi

echo "VS Code and dependencies installation completed successfully!"
echo "You can now use the following scripts:"
echo "  - ./test-vscode.sh: Test VS Code with virtual display"
echo "  - ./install-roocode-extension.sh: Install Roo Code extension for VS Code"
echo ""
echo "For more information, see README-vscode-setup.md"