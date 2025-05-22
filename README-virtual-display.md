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
