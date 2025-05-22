#!/bin/bash
# install.sh
# Master installation script for Roo Code on Ubuntu AWS
# This script combines all the individual installation steps into a single process

set -e  # Exit immediately if a command exits with a non-zero status

echo "=========================================================="
echo "Roo Code Installation for Ubuntu AWS"
echo "=========================================================="
echo ""
echo "This script will install and configure Roo Code to run on Ubuntu AWS."
echo "The installation process includes:"
echo "1. Setting up a virtual display environment"
echo "2. Installing VS Code and dependencies"
echo "3. Setting up the Roo Code CLI"
echo "4. Configuring remote access (optional)"
echo ""
echo "The installation may take 10-15 minutes to complete."
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the installation? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Installation cancelled."
  exit 0
fi

# Create a log file
LOG_FILE="roocode_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Installation started at $(date)"
echo "Log file: $LOG_FILE"
echo ""

# Function to display section header
section() {
  echo ""
  echo "=========================================================="
  echo "$1"
  echo "=========================================================="
  echo ""
}

# Function to check if a command succeeded
check_status() {
  if [ $? -eq 0 ]; then
    echo "✅ $1 completed successfully."
  else
    echo "❌ $1 failed. Please check the log file for details."
    exit 1
  fi
}

# Create installation directory
INSTALL_DIR="$HOME/roocode-ubuntu"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Ask for repository URL
REPO_URL="https://github.com/your-repo/Roo-Code.git"
read -p "Enter the Roo Code repository URL (default: $REPO_URL): " input_repo_url
REPO_URL=${input_repo_url:-$REPO_URL}

# Ask for OpenAI API key
read -p "Enter your OpenAI API key: " OPENAI_API_KEY

# Step 1: Set up virtual display environment
section "Step 1: Setting up virtual display environment"

cat > 1_setup_virtual_display.sh << 'EOL'
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
cat > start-xvfb.sh << 'EOLXVFB'
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
EOLXVFB

chmod +x start-xvfb.sh

# Step 3: Create a script to stop Xvfb
echo "Creating Xvfb stop script..."
cat > stop-xvfb.sh << 'EOLXVFB'
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
EOLXVFB

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

echo "Virtual display environment setup completed successfully!"
EOL

chmod +x 1_setup_virtual_display.sh
./1_setup_virtual_display.sh
check_status "Virtual display setup"

# Step 2: Install VS Code and dependencies
section "Step 2: Installing VS Code and dependencies"

cat > 2_install_vscode_dependencies.sh << 'EOL'
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
sudo apt-get install -y libx11-xcb1 libxcb-dri3-0 libdrm2 libgbm1 libasound2 libxkbfile1 libsecret-1-0

echo "VS Code and dependencies installation completed successfully!"
EOL

chmod +x 2_install_vscode_dependencies.sh
./2_install_vscode_dependencies.sh
check_status "VS Code and dependencies installation"

# Step 3: Set up Roo Code CLI
section "Step 3: Setting up Roo Code CLI"

cat > 3_setup_roocode_cli.sh << EOL
#!/bin/bash
# 3_setup_roocode_cli.sh
# This script sets up the Roo Code repository and modifies the CLI to work with the virtual display on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Roo Code repository and modifying CLI for Ubuntu..."

# Step 1: Clone the Roo Code repository
echo "Cloning Roo Code repository..."
REPO_URL="${REPO_URL}"
REPO_DIR="Roo-Code"

if [ -d "\$REPO_DIR" ]; then
  echo "Repository directory already exists. Updating..."
  cd "\$REPO_DIR"
  git pull
  cd ..
else
  git clone "\$REPO_URL" "\$REPO_DIR"
fi

# Step 2: Install dependencies
echo "Installing dependencies..."
cd "\$REPO_DIR"
pnpm install

# Step 3: Create backup of original files
echo "Creating backup of original files..."
if [ -f "evals/apps/cli/src/index.ts" ]; then
  cp evals/apps/cli/src/index.ts evals/apps/cli/src/index.ts.bak
  echo "Backup created: evals/apps/cli/src/index.ts.bak"
fi

# Step 4: Modify the VS Code launch command
echo "Modifying VS Code launch command..."
if [ -f "evals/apps/cli/src/index.ts" ]; then
  # Create a patch file for the modifications
  cat > ubuntu-cli-patch.diff << 'EOLDIFF'
--- index.ts.bak	2025-05-22 12:00:00.000000000 +0000
+++ index.ts	2025-05-22 12:00:00.000000000 +0000
@@ -197,7 +197,10 @@
 	await execa({
 		env: {
 			ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,
+			DISPLAY: process.env.DISPLAY || ":1", // Use the virtual display
 		},
 		shell: "/bin/bash",
 	})\`code --disable-workspace-trust -n \${workspacePath}\`
 
+	// Give VS Code some time to initialize
+	await new Promise((resolve) => setTimeout(resolve, 3_000))
@@ -210,7 +213,8 @@
 	console.log(\`\${Date.now()} [cli#runExercise] Connecting to \${taskSocketPath}\`)
 	const client = new IpcClient(taskSocketPath)
 
+	const ipcTimeout = process.env.ROO_CODE_IPC_TIMEOUT ? parseInt(process.env.ROO_CODE_IPC_TIMEOUT) : 10_000;
 	try {
-		await pWaitFor(() => client.isReady, { interval: 250, timeout: 5_000 })
+		await pWaitFor(() => client.isReady, { interval: 250, timeout: ipcTimeout })
 		// eslint-disable-next-line @typescript-eslint/no-unused-vars
 	} catch (error) {
EOLDIFF

  # Apply the patch
  echo "Applying patch to evals/apps/cli/src/index.ts..."
  patch -p0 evals/apps/cli/src/index.ts ubuntu-cli-patch.diff || {
    echo "Patch failed. Manually modifying the file..."
    
    # Manually modify the file if patch fails
    sed -i 's/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,/ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,\\n\\t\\t\\tDISPLAY: process.env.DISPLAY || ":1", \\/\\/ Use the virtual display/g' evals/apps/cli/src/index.ts
    
    # Add delay after VS Code launch
    sed -i '/code --disable-workspace-trust -n \${workspacePath}\`/a\\\\n\\t\\/\\/ Give VS Code some time to initialize\\n\\tawait new Promise((resolve) => setTimeout(resolve, 3_000))' evals/apps/cli/src/index.ts
    
    # Increase IPC timeout
    sed -i 's/await pWaitFor(() => client.isReady, { interval: 250, timeout: 5_000 })/const ipcTimeout = process.env.ROO_CODE_IPC_TIMEOUT ? parseInt(process.env.ROO_CODE_IPC_TIMEOUT) : 10_000;\\n\\tawait pWaitFor(() => client.isReady, { interval: 250, timeout: ipcTimeout })/g' evals/apps/cli/src/index.ts
  }
  
  echo "Modifications applied to evals/apps/cli/src/index.ts"
else
  echo "Error: evals/apps/cli/src/index.ts not found. Please check the repository structure."
  exit 1
fi

# Step 5: Create environment variables file
echo "Creating environment variables file..."
if [ ! -f ".env" ]; then
  cat > .env << EOLENV
# Remote Implementation Configuration
REMOTE_IMPLEMENTATION_SIMULATION_MODE=false
FALLBACK_TO_SIMULATION=false
NEXT_PUBLIC_USE_POLLING=true

# API Keys
OPENAI_API_KEY='${OPENAI_API_KEY}'

# Ubuntu-specific configuration
ROO_CODE_IPC_TIMEOUT=10000
EOLENV
  echo ".env file created with the provided API key."
else
  echo ".env file already exists. Please ensure it contains the necessary API keys."
fi

# Step 6: Create export script
echo "Creating export script..."
if [ ! -f "export-env.sh" ]; then
  cat > export-env.sh << 'EOLENV'
#!/bin/bash

# Load .env file and export variables
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines
  if [[ $line =~ ^[[:space:]]*$ || $line =~ ^[[:space:]]*# ]]; then
    continue
  fi
  
  # Remove leading/trailing whitespace
  line=$(echo "$line" | xargs)
  
  # Export the variable
  export "$line"
  
  # Extract variable name for display
  var_name=$(echo "$line" | cut -d= -f1)
  echo "Exported: $var_name"
done < .env

# Verify a few key variables (optional)
echo -e "\nVerification:"
echo "OPENAI_API_KEY: ${OPENAI_API_KEY:0:5}..."
echo "ROO_CODE_IPC_TIMEOUT: $ROO_CODE_IPC_TIMEOUT"
EOLENV
  chmod +x export-env.sh
  echo "export-env.sh created and made executable."
else
  echo "export-env.sh already exists."
fi

# Step 7: Create CLI wrapper script
echo "Creating CLI wrapper script..."
cat > run-cli.sh << 'EOLCLI'
#!/bin/bash
# run-cli.sh - Run Roo Code CLI with virtual display

# Start Xvfb if not already running
if ! pgrep -x Xvfb > /dev/null; then
  export DISPLAY=:1
  Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
  echo "Started Xvfb with PID $!"
  # Give Xvfb some time to initialize
  sleep 2
fi

# Export environment variables
source ./export-env.sh

# Set additional environment variables for Ubuntu
export DISPLAY=:1
export ROO_CODE_IPC_TIMEOUT=10000

# Run the CLI
cd evals
pnpm cli "$@"
EOLCLI
chmod +x run-cli.sh
echo "run-cli.sh created and made executable."

echo "Roo Code CLI setup completed successfully!"
EOL

chmod +x 3_setup_roocode_cli.sh
./3_setup_roocode_cli.sh
check_status "Roo Code CLI setup"

# Step 4: Set up remote access (optional)
section "Step 4: Setting up remote access (optional)"

read -p "Do you want to set up remote access to VS Code? (y/n): " setup_remote
if [[ $setup_remote == "y" || $setup_remote == "Y" ]]; then
  cp 4_setup_remote_access.sh 4_setup_remote_access.sh 2>/dev/null || {
    cat > 4_setup_remote_access.sh << 'EOL'
#!/bin/bash
# 4_setup_remote_access.sh
# This script sets up remote access to the VS Code UI running on the AWS instance

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up remote access to VS Code on Ubuntu AWS..."

# Function to display menu
display_menu() {
  echo "Please select a remote access method:"
  echo "1) SSH Tunneling with X11 Forwarding"
  echo "2) VNC Server"
  echo "3) Code Server (VS Code in Browser)"
  echo "4) All of the above"
  echo "5) Exit"
  read -p "Enter your choice (1-5): " choice
  return $choice
}

# Function to setup X11 Forwarding
setup_x11_forwarding() {
  echo "Setting up SSH with X11 Forwarding..."
  
  # Install X11 packages
  sudo apt-get update
  sudo apt-get install -y x11-apps
  
  # Configure SSH server for X11 Forwarding
  if ! grep -q "^X11Forwarding yes" /etc/ssh/sshd_config; then
    echo "Configuring SSH server for X11 Forwarding..."
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # Enable X11 Forwarding
    sudo sed -i 's/#X11Forwarding no/X11Forwarding yes/g' /etc/ssh/sshd_config
    sudo sed -i 's/#X11Forwarding yes/X11Forwarding yes/g' /etc/ssh/sshd_config
    
    # Set X11 Display Offset
    if ! grep -q "X11DisplayOffset" /etc/ssh/sshd_config; then
      echo "X11DisplayOffset 10" | sudo tee -a /etc/ssh/sshd_config
    else
      sudo sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config
    fi
    
    # Restart SSH service
    sudo systemctl restart sshd
  else
    echo "X11 Forwarding is already enabled in SSH config."
  fi
  
  # Create a test script
  cat > test-x11-forwarding.sh << 'EOLX11'
#!/bin/bash
# test-x11-forwarding.sh - Test X11 Forwarding

echo "Testing X11 Forwarding..."
echo "DISPLAY=$DISPLAY"

if [ -z "$DISPLAY" ]; then
  echo "Error: DISPLAY environment variable is not set."
  echo "Make sure you're connecting with X11 forwarding enabled:"
  echo "  ssh -X -i your-key.pem ubuntu@your-aws-instance"
  exit 1
fi

# Check if xeyes is installed
if ! command -v xeyes &> /dev/null; then
  echo "Installing xeyes..."
  sudo apt-get install -y x11-apps
fi

# Run xeyes to test X11 forwarding
echo "Running xeyes to test X11 forwarding..."
xeyes
EOLX11
  chmod +x test-x11-forwarding.sh
  
  echo "X11 Forwarding setup completed successfully!"
}

# Function to setup VNC Server
setup_vnc_server() {
  echo "Setting up VNC Server..."
  
  # Install VNC Server and desktop environment
  sudo apt-get update
  sudo apt-get install -y tightvncserver xfce4 xfce4-goodies
  
  # Create VNC password
  echo "Setting up VNC password..."
  mkdir -p ~/.vnc
  
  # Create a script to set VNC password non-interactively
  cat > set-vnc-password.sh << 'EOLVNC'
#!/bin/bash
# set-vnc-password.sh - Set VNC password non-interactively

# Default password
VNC_PASSWORD=${1:-"password"}

# Create expect script
cat > set_passwd.exp << EOF
#!/usr/bin/expect -f
spawn vncpasswd
expect "Password:"
send "$VNC_PASSWORD\r"
expect "Verify:"
send "$VNC_PASSWORD\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
exit
EOF

# Make it executable
chmod +x set_passwd.exp

# Run expect script
./set_passwd.exp

# Clean up
rm set_passwd.exp
EOLVNC
  chmod +x set-vnc-password.sh
  
  # Run the script with default password
  if ! command -v expect &> /dev/null; then
    sudo apt-get install -y expect
  fi
  ./set-vnc-password.sh "password"
  rm set-vnc-password.sh
  
  # Create VNC startup script
  cat > ~/.vnc/xstartup << 'EOLVNC'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOLVNC
  chmod +x ~/.vnc/xstartup
  
  # Create VNC server start script
  cat > start-vnc-server.sh << 'EOLVNC'
#!/bin/bash
# start-vnc-server.sh - Start VNC server

# Kill existing VNC server
vncserver -kill :1 2>/dev/null || true

# Start VNC server
vncserver :1 -geometry 1280x800 -depth 24

echo "VNC server started on display :1"
echo "To connect, create an SSH tunnel on your local machine:"
echo "  ssh -L 5901:localhost:5901 -i your-key.pem ubuntu@your-aws-instance"
echo "Then connect to localhost:5901 with your VNC client"
EOLVNC
  chmod +x start-vnc-server.sh
  
  # Create VNC server stop script
  cat > stop-vnc-server.sh << 'EOLVNC'
#!/bin/bash
# stop-vnc-server.sh - Stop VNC server

vncserver -kill :1
echo "VNC server stopped"
EOLVNC
  chmod +x stop-vnc-server.sh
  
  echo "VNC Server setup completed successfully!"
}

# Function to setup Code Server
setup_code_server() {
  echo "Setting up Code Server (VS Code in Browser)..."
  
  # Install code-server
  if ! command -v code-server &> /dev/null; then
    echo "Installing code-server..."
    curl -fsSL https://code-server.dev/install.sh | sh
  else
    echo "code-server is already installed."
  fi
  
  # Configure code-server
  mkdir -p ~/.config/code-server
  cat > ~/.config/code-server/config.yaml << 'EOLCS'
bind-addr: 127.0.0.1:8080
auth: password
password: password
cert: false
EOLCS
  
  # Create start script
  cat > start-code-server.sh << 'EOLCS'
#!/bin/bash
# start-code-server.sh - Start code-server

# Kill existing code-server
pkill -f code-server || true

# Start code-server
code-server --disable-telemetry &
echo $! > /tmp/code-server.pid

echo "code-server started on port 8080"
echo "To connect, create an SSH tunnel on your local machine:"
echo "  ssh -L 8080:localhost:8080 -i your-key.pem ubuntu@your-aws-instance"
echo "Then open a browser and navigate to: http://localhost:8080"
echo "Password: password (change in ~/.config/code-server/config.yaml)"
EOLCS
  chmod +x start-code-server.sh
  
  # Create stop script
  cat > stop-code-server.sh << 'EOLCS'
#!/bin/bash
# stop-code-server.sh - Stop code-server

if [ -f /tmp/code-server.pid ]; then
  kill $(cat /tmp/code-server.pid) 2>/dev/null || true
  rm /tmp/code-server.pid
  echo "code-server stopped"
else
  pkill -f code-server || true
  echo "code-server stopped"
fi
EOLCS
  chmod +x stop-code-server.sh
  
  echo "Code Server setup completed successfully!"
}

# Main script
echo "This script will set up remote access to VS Code on your Ubuntu AWS instance."
echo "You can choose from several remote access methods."
echo ""

display_menu
choice=$?

case $choice in
  1)
    setup_x11_forwarding
    ;;
  2)
    setup_vnc_server
    ;;
  3)
    setup_code_server
    ;;
  4)
    setup_x11_forwarding
    setup_vnc_server
    setup_code_server
    echo "All remote access methods have been set up successfully!"
    ;;
  5)
    echo "Exiting without setting up remote access."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "Remote access setup completed successfully!"
EOL
  }

  chmod +x 4_setup_remote_access.sh
  ./4_setup_remote_access.sh
  check_status "Remote access setup"
else
  echo "Skipping remote access setup."
fi

# Create a README file
section "Creating README file"

cat > README.md << EOL
# Roo Code on Ubuntu AWS

This directory contains the installation of Roo Code on Ubuntu AWS.

## Installation Summary

- Virtual display environment: Xvfb
- VS Code and dependencies installed
- Roo Code CLI configured for Ubuntu
- Remote access methods (if selected)

## Usage

1. Start the virtual display:
   \`\`\`bash
   ./start-xvfb.sh
   \`\`\`

2. Run Roo Code CLI:
   \`\`\`bash
   cd Roo-Code
   ./run-cli.sh python hello_world
   \`\`\`

## Remote Access

${setup_remote:+Remote access has been set up. See the README files in the respective directories for details.}
${setup_remote:-Remote access has not been set up. You can set it up later by running ./4_setup_remote_access.sh}

## Troubleshooting

If you encounter issues:

1. Check if Xvfb is running:
   \`\`\`bash
   ps aux | grep Xvfb
   \`\`\`

2. Verify VS Code installation:
   \`\`\`bash
   code --version
   \`\`\`

3. Check the log file:
   \`\`\`bash
   cat $LOG_FILE
   \`\`\`

## Files

- \`start-xvfb.sh\`: Start the virtual display
- \`stop-xvfb.sh\`: Stop the virtual display
- \`Roo-Code/run-cli.sh\`: Run Roo Code CLI with virtual display
- \`Roo-Code/export-env.sh\`: Export environment variables
EOL

echo "README.md created."

# Create a symbolic link to the Roo Code run-cli.sh script
ln -sf "$INSTALL_DIR/Roo-Code/run-cli.sh" "$INSTALL_DIR/run-roocode.sh"
echo "Created symbolic link: run-roocode.sh -> Roo-Code/run-cli.sh"

section "Installation Complete"

echo "Roo Code has been successfully installed on Ubuntu AWS!"
echo ""
echo "To run Roo Code:"
echo "1. Start the virtual display (if not already running):"
echo "   ./start-xvfb.sh"
echo ""
echo "2. Run Roo Code CLI:"
echo "   ./run-roocode.sh python hello_world"
echo ""
echo "For more information, see README.md"
echo ""
echo "Installation completed at $(date)"