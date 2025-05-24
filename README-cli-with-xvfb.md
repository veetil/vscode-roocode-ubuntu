# Running Roo Code CLI with Virtual Display

This README explains how to use the `run-cli-with-xvfb.sh` script to run the Roo Code CLI with a virtual display, which allows VS Code to run in a headless environment without user intervention.

## Background

The Roo Code CLI (`pnpm cli python grep`) launches VS Code with the Roo Code extension and activates it using an IPC interface. However, in headless environments, VS Code may encounter several issues:

1. OS keyring prompts
2. Workspace trust popups
3. ServiceWorker registration errors
4. VS Code terminal integration issues

The `run-cli-with-xvfb.sh` script addresses these issues by setting up a virtual display with optimized configuration and launching VS Code with the appropriate flags and environment variables.

## Prerequisites

- Ubuntu Linux (or compatible distribution)
- Node.js and pnpm installed
- Roo Code repository cloned

## Usage

### Basic Usage

To run the Roo Code CLI with a virtual display:

```bash
./run-cli-with-xvfb.sh python grep
```

**Note**: The script can be run from any directory. It will automatically change to the correct directory (`~/LaunchRoo/Roo-Code/evals`) to run the CLI command.

This will:
1. Set up a virtual display using Xvfb
2. Configure environment variables for optimal rendering
3. Run the CLI command `pnpm cli python grep`

### Clearing VS Code Cache

If you encounter issues with VS Code, you can clear its cache:

```bash
./run-cli-with-xvfb.sh --clear-cache python grep
```

This will kill any running VS Code processes and clear the cache before running the command.

### Taking a Screenshot

To verify that VS Code is rendering correctly, you can take a screenshot:

```bash
./run-cli-with-xvfb.sh --screenshot python grep
```

This will take a screenshot after running the command and save it with a timestamp.

## Troubleshooting

### VS Code Doesn't Launch

If VS Code doesn't launch, check:

1. VS Code installation: `which code`
2. Xvfb process: `ps aux | grep Xvfb`
3. DISPLAY environment variable: `echo $DISPLAY`

### Blank or Corrupted Display

If VS Code launches but shows a blank or corrupted display:

1. Try clearing the VS Code cache: `./run-cli-with-xvfb.sh --clear-cache python grep`
2. Check if all dependencies are installed: `sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libgbm1`
3. Verify Xvfb configuration: `xdpyinfo | grep "dimensions"`

### Terminal Integration Warning

If you see a warning about VS Code terminal integration:

1. This warning is informational and doesn't affect functionality
2. You can disable it in the Roo Code extension settings

## How It Works

The script:

1. Starts Xvfb with optimized settings (1920x1080x24, GLX extension, 96 DPI)
2. Sets environment variables (`LIBGL_ALWAYS_SOFTWARE=1`, `ELECTRON_DISABLE_GPU=1`)
3. Ensures VS Code and its dependencies are installed
4. Runs the CLI command with the virtual display

## Advanced Configuration

You can modify the script to:

1. Change the display number (default: `:1`)
2. Adjust the screen resolution (default: `1920x1080x24`)
3. Add additional VS Code flags
4. Modify environment variables

## Related Files

- `vscode-virtual-display-research.md`: Detailed research on VS Code with virtual display
- `ubuntu_roocode_implementation/`: Original implementation of virtual display for VS Code