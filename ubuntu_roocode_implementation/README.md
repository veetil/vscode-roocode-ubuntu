# Ubuntu Roo Code Implementation

This directory contains the implementation of the plan to port Roo Code autostart functionality to Ubuntu running on AWS instances. We're implementing the plan step by step, testing each component thoroughly before moving to the next one.

## Step 1: Virtual Display Environment

The first step is to set up a virtual display environment using Xvfb on Ubuntu. This is necessary because Roo Code requires a graphical interface as it launches VS Code with a GUI.

### Implementation

The `1_setup_virtual_display.sh` script:

1. Installs Xvfb and X11 utilities
2. Creates scripts to start and stop Xvfb
3. Tests the virtual display
4. Creates a systemd service for Xvfb (optional)
5. Creates helper scripts to run commands with the virtual display
6. Creates a script to take screenshots of the virtual display

### Usage

To set up the virtual display environment:

```bash
./1_setup_virtual_display.sh
```

This will create several utility scripts:

- `start-xvfb.sh`: Start the Xvfb virtual display
- `stop-xvfb.sh`: Stop the Xvfb virtual display
- `run-with-xvfb.sh`: Run a command with the virtual display
- `take-screenshot.sh`: Take a screenshot of the virtual display

### Testing

After running the script, you can test the virtual display by:

1. Checking if Xvfb is running:
   ```bash
   ps aux | grep Xvfb
   ```

2. Verifying the DISPLAY environment variable:
   ```bash
   echo $DISPLAY
   ```

3. Testing the display with xdpyinfo:
   ```bash
   export DISPLAY=:1
   xdpyinfo | grep "dimensions"
   ```

4. Running a simple GUI application:
   ```bash
   ./run-with-xvfb.sh xeyes
   ```

## Next Steps

After successfully implementing and testing the virtual display environment, we'll proceed to:

1. Step 2: Install VS Code and dependencies
2. Step 3: Set up the Roo Code CLI
3. Step 4: Configure remote access (optional)

Each step will be implemented and tested thoroughly before moving to the next one.