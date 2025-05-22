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
  cat > test-x11-forwarding.sh << 'EOL'
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
EOL
  chmod +x test-x11-forwarding.sh
  
  # Create README
  cat > README-x11-forwarding.md << 'EOL'
# X11 Forwarding Setup for Roo Code on Ubuntu AWS

This guide explains how to use X11 forwarding to access the VS Code UI running on your AWS instance.

## Prerequisites

- X11 server installed on your local machine:
  - macOS: Install XQuartz (https://www.xquartz.org/)
  - Linux: Built-in X11 server
  - Windows: Install VcXsrv (https://sourceforge.net/projects/vcxsrv/) or Xming

## Connecting with X11 Forwarding

From your local machine, connect to the AWS instance with X11 forwarding enabled:

```bash
ssh -X -i your-key.pem ubuntu@your-aws-instance
```

For better performance, use the `-Y` flag (trusted X11 forwarding):

```bash
ssh -Y -i your-key.pem ubuntu@your-aws-instance
```

## Testing X11 Forwarding

Once connected, run the test script:

```bash
./test-x11-forwarding.sh
```

You should see the xeyes application appear on your local display.

## Running VS Code

After confirming X11 forwarding works, you can run VS Code:

```bash
code --disable-workspace-trust -n /path/to/workspace
```

## Troubleshooting

If you encounter issues with X11 forwarding:

1. Verify the DISPLAY environment variable is set:
   ```bash
   echo $DISPLAY
   ```

2. On your local machine, ensure X11 server is running and allows connections:
   ```bash
   # macOS with XQuartz
   xhost +
   
   # Linux
   xhost +
   
   # Windows with VcXsrv
   # Make sure to enable "No Access Control" when starting VcXsrv
   ```

3. Check SSH connection with verbose logging:
   ```bash
   ssh -vvv -X -i your-key.pem ubuntu@your-aws-instance
   ```

4. If using AWS EC2, ensure security groups allow SSH traffic (port 22).
EOL
  
  echo "X11 Forwarding setup completed successfully!"
  echo "To use X11 Forwarding:"
  echo "1. Connect to your AWS instance with: ssh -X -i your-key.pem ubuntu@your-aws-instance"
  echo "2. Run the test script: ./test-x11-forwarding.sh"
  echo ""
  echo "For more information, see README-x11-forwarding.md"
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
  cat > set-vnc-password.sh << 'EOL'
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
EOL
  chmod +x set-vnc-password.sh
  
  # Run the script with default password
  if ! command -v expect &> /dev/null; then
    sudo apt-get install -y expect
  fi
  ./set-vnc-password.sh "password"
  rm set-vnc-password.sh
  
  # Create VNC startup script
  cat > ~/.vnc/xstartup << 'EOL'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOL
  chmod +x ~/.vnc/xstartup
  
  # Create VNC server start script
  cat > start-vnc-server.sh << 'EOL'
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
EOL
  chmod +x start-vnc-server.sh
  
  # Create VNC server stop script
  cat > stop-vnc-server.sh << 'EOL'
#!/bin/bash
# stop-vnc-server.sh - Stop VNC server

vncserver -kill :1
echo "VNC server stopped"
EOL
  chmod +x stop-vnc-server.sh
  
  # Create README
  cat > README-vnc-server.md << 'EOL'
# VNC Server Setup for Roo Code on Ubuntu AWS

This guide explains how to use VNC to access the VS Code UI running on your AWS instance.

## Starting VNC Server

Run the start script:

```bash
./start-vnc-server.sh
```

## Connecting to VNC Server

1. Create an SSH tunnel from your local machine:

```bash
ssh -L 5901:localhost:5901 -i your-key.pem ubuntu@your-aws-instance
```

2. Use a VNC client to connect to:

```
localhost:5901
```

3. Enter the VNC password you set during setup.

## Running VS Code in VNC Session

In the VNC session, open a terminal and run:

```bash
code --disable-workspace-trust -n /path/to/workspace
```

## Stopping VNC Server

Run the stop script:

```bash
./stop-vnc-server.sh
```

## Changing VNC Password

To change the VNC password:

```bash
vncpasswd
```

## Troubleshooting

If you encounter issues with VNC:

1. Check if VNC server is running:
   ```bash
   ps aux | grep Xtightvnc
   ```

2. Restart VNC server:
   ```bash
   ./stop-vnc-server.sh
   ./start-vnc-server.sh
   ```

3. Check VNC server logs:
   ```bash
   cat ~/.vnc/*.log
   ```

4. Verify SSH tunnel is working:
   ```bash
   netstat -tuln | grep 5901
   ```
EOL
  
  echo "VNC Server setup completed successfully!"
  echo "To start VNC Server: ./start-vnc-server.sh"
  echo "To stop VNC Server: ./stop-vnc-server.sh"
  echo ""
  echo "For more information, see README-vnc-server.md"
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
  cat > ~/.config/code-server/config.yaml << 'EOL'
bind-addr: 127.0.0.1:8080
auth: password
password: password
cert: false
EOL
  
  # Create start script
  cat > start-code-server.sh << 'EOL'
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
EOL
  chmod +x start-code-server.sh
  
  # Create stop script
  cat > stop-code-server.sh << 'EOL'
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
EOL
  chmod +x stop-code-server.sh
  
  # Create README
  cat > README-code-server.md << 'EOL'
# Code Server Setup for Roo Code on Ubuntu AWS

This guide explains how to use code-server to access VS Code in a browser from your AWS instance.

## Starting Code Server

Run the start script:

```bash
./start-code-server.sh
```

## Connecting to Code Server

1. Create an SSH tunnel from your local machine:

```bash
ssh -L 8080:localhost:8080 -i your-key.pem ubuntu@your-aws-instance
```

2. Open a browser on your local machine and navigate to:

```
http://localhost:8080
```

3. Enter the password (default: "password").

## Installing Roo Code Extension

In code-server:

1. Click the Extensions icon in the sidebar
2. Search for "Roo Code"
3. Install the extension

## Stopping Code Server

Run the stop script:

```bash
./stop-code-server.sh
```

## Changing Password

Edit the configuration file:

```bash
nano ~/.config/code-server/config.yaml
```

Change the password line and restart code-server.

## Troubleshooting

If you encounter issues with code-server:

1. Check if code-server is running:
   ```bash
   ps aux | grep code-server
   ```

2. Check code-server logs:
   ```bash
   cat ~/.local/share/code-server/logs/code-server.log
   ```

3. Verify SSH tunnel is working:
   ```bash
   netstat -tuln | grep 8080
   ```

4. Try running code-server with verbose logging:
   ```bash
   code-server --verbose
   ```
EOL
  
  echo "Code Server setup completed successfully!"
  echo "To start Code Server: ./start-code-server.sh"
  echo "To stop Code Server: ./stop-code-server.sh"
  echo ""
  echo "For more information, see README-code-server.md"
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
    
    # Create a combined README
    cat > README-remote-access.md << 'EOL'
# Remote Access Options for Roo Code on Ubuntu AWS

This guide provides an overview of the different remote access methods available for accessing VS Code on your AWS instance.

## Option 1: SSH Tunneling with X11 Forwarding

Best for: Direct GUI application forwarding with minimal setup.

```bash
ssh -X -i your-key.pem ubuntu@your-aws-instance
```

See README-x11-forwarding.md for details.

## Option 2: VNC Server

Best for: Full desktop environment with persistent sessions.

```bash
# On AWS instance
./start-vnc-server.sh

# On local machine
ssh -L 5901:localhost:5901 -i your-key.pem ubuntu@your-aws-instance
```

Then connect to localhost:5901 with your VNC client.

See README-vnc-server.md for details.

## Option 3: Code Server (VS Code in Browser)

Best for: Browser-based access without additional client software.

```bash
# On AWS instance
./start-code-server.sh

# On local machine
ssh -L 8080:localhost:8080 -i your-key.pem ubuntu@your-aws-instance
```

Then open http://localhost:8080 in your browser.

See README-code-server.md for details.

## Choosing the Right Method

- **X11 Forwarding**: Simplest option, but requires X11 server on local machine and can be slow over high-latency connections.
- **VNC Server**: Provides a full desktop environment and persistent sessions, but requires a VNC client.
- **Code Server**: Browser-based access with native VS Code experience, but may have some extension compatibility issues.

For the best experience with Roo Code, we recommend:
1. Code Server for most users
2. VNC Server for users who need a full desktop environment
3. X11 Forwarding for quick access or troubleshooting
EOL
    
    echo "All remote access methods have been set up successfully!"
    echo "For an overview of all methods, see README-remote-access.md"
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