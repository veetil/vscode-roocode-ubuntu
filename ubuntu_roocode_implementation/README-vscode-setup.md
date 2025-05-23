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
