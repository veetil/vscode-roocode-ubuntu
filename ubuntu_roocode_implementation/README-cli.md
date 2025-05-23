# Roo Code CLI Setup for Ubuntu

This directory contains scripts to set up and run the Roo Code CLI with a virtual display on Ubuntu.

## Scripts

- `run-cli.sh`: Run Roo Code CLI with virtual display
- `test-cli.sh`: Test Roo Code CLI with a simple exercise

## Usage

1. Update the `.env` file with your API keys:
   ```bash
   nano ../.env
   ```

2. Export environment variables:
   ```bash
   source ../export-env.sh
   ```

3. Run Roo Code CLI:
   ```bash
   ./run-cli.sh python hello_world
   ```

4. Test the CLI:
   ```bash
   ./test-cli.sh
   ```

## Modifications

The following modifications have been made to make Roo Code work on Ubuntu:

1. VS Code launch command modified to use the virtual display
2. Added delay after VS Code launch to give it time to initialize
3. Increased IPC connection timeout to account for potentially slower startup on Ubuntu
4. Created wrapper scripts to set up the environment correctly

## Troubleshooting

If you encounter issues with the CLI:

1. Check if Xvfb is running:
   ```bash
   ps aux | grep Xvfb
   ```

2. Verify the DISPLAY environment variable:
   ```bash
   echo $DISPLAY
   ```

3. Check VS Code logs:
   ```bash
   cat ~/.config/Code/logs/main.log
   ```

4. Increase the IPC timeout:
   ```bash
   export ROO_CODE_IPC_TIMEOUT=20000
   ```

5. Run with verbose logging:
   ```bash
   DISPLAY=:1 code --verbose --log debug
   ```
