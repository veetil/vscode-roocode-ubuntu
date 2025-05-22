# Roo Code Ubuntu AWS Implementation

This directory contains the implementation scripts for porting Roo Code to Ubuntu running on AWS instances. These scripts automate the setup process described in the plan documents.

## Quick Start

For a complete installation, run the master installation script:

```bash
chmod +x install.sh
./install.sh
```

This script will guide you through the entire installation process, including:
1. Setting up a virtual display environment
2. Installing VS Code and dependencies
3. Setting up the Roo Code CLI
4. Configuring remote access (optional)

## Individual Scripts

If you prefer to run the installation steps individually, you can use the following scripts:

### 1. Setup Virtual Display

```bash
chmod +x 1_setup_virtual_display.sh
./1_setup_virtual_display.sh
```

This script:
- Installs Xvfb and X11 utilities
- Creates scripts to start and stop the virtual display
- Tests the virtual display to ensure it's working correctly

### 2. Install VS Code and Dependencies

```bash
chmod +x 2_install_vscode_dependencies.sh
./2_install_vscode_dependencies.sh
```

This script:
- Installs prerequisites (wget, gpg, apt-transport-https, etc.)
- Installs Node.js 18.x and pnpm
- Installs VS Code
- Installs Python and related tools
- Installs additional dependencies for VS Code

### 3. Setup Roo Code CLI

```bash
chmod +x 3_setup_roocode_cli.sh
./3_setup_roocode_cli.sh
```

This script:
- Clones the Roo Code repository
- Installs dependencies
- Modifies the VS Code launch command to work with the virtual display
- Increases the IPC connection timeout
- Creates environment variables file and export script
- Creates a CLI wrapper script

### 4. Setup Remote Access

```bash
chmod +x 4_setup_remote_access.sh
./4_setup_remote_access.sh
```

This script:
- Provides options for remote access:
  - SSH Tunneling with X11 Forwarding
  - VNC Server
  - Code Server (VS Code in Browser)
- Sets up the selected remote access method(s)
- Creates scripts to start and stop the remote access service(s)

## Usage After Installation

After installation, you can run Roo Code with:

```bash
# Start the virtual display (if not already running)
./start-xvfb.sh

# Run Roo Code CLI
cd Roo-Code
./run-cli.sh python hello_world
```

Or, if you used the master installation script:

```bash
./run-roocode.sh python hello_world
```

## Remote Access

Depending on the remote access method you chose:

### SSH Tunneling with X11 Forwarding

From your local machine:

```bash
ssh -X -i your-key.pem ubuntu@your-aws-instance
```

### VNC Server

From your local machine:

```bash
# Create SSH tunnel
ssh -L 5901:localhost:5901 -i your-key.pem ubuntu@your-aws-instance

# Then connect to localhost:5901 with your VNC client
```

### Code Server

From your local machine:

```bash
# Create SSH tunnel
ssh -L 8080:localhost:8080 -i your-key.pem ubuntu@your-aws-instance

# Then open http://localhost:8080 in your browser
```

## Troubleshooting

### Virtual Display Issues

If you encounter issues with the virtual display:

```bash
# Check if Xvfb is running
ps aux | grep Xvfb

# Restart Xvfb
./stop-xvfb.sh
./start-xvfb.sh

# Verify the DISPLAY environment variable
echo $DISPLAY
```

### VS Code Issues

If you encounter issues with VS Code:

```bash
# Check VS Code version
code --version

# Check VS Code logs
cat ~/.config/Code/logs/main.log

# Run VS Code with verbose logging
DISPLAY=:1 code --verbose --log debug
```

### CLI Issues

If you encounter issues with the Roo Code CLI:

```bash
# Increase IPC timeout
export ROO_CODE_IPC_TIMEOUT=20000
./run-cli.sh python hello_world

# Check for errors in the CLI
cd Roo-Code/evals
DISPLAY=:1 pnpm cli python hello_world --verbose
```

### Remote Access Issues

If you encounter issues with remote access:

```bash
# For VNC Server
vncserver -kill :1
./start-vnc-server.sh

# For Code Server
./stop-code-server.sh
./start-code-server.sh
```

## Customization

You can customize the installation by editing the scripts before running them. Key parameters you might want to change:

- Repository URL in `3_setup_roocode_cli.sh`
- OpenAI API key in `.env` file
- VNC password in `4_setup_remote_access.sh`
- Code Server password in `~/.config/code-server/config.yaml`

## Security Considerations

- The default passwords for VNC and Code Server are set to "password". Change these to secure passwords in a production environment.
- Use SSH key authentication instead of password authentication.
- Consider setting up HTTPS for Code Server if exposing it directly.
- Use SSH tunneling to secure VNC and Code Server connections.