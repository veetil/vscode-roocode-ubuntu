# VS Code Display Fix for Virtual Display

## Issue

When running VS Code with the Xvfb virtual display, screenshots show a blank screen (1-bit grayscale PNG) while other applications like Emacs render correctly (8-bit/color RGB). This issue occurs because VS Code's Electron-based interface requires additional configuration to render properly in a virtual display environment.

## Analysis

The issue was identified by examining the screenshots:
- `screenshot-20250522-190435.png`: 27761 bytes, 8-bit/color RGB (working correctly)
- `screenshot-20250522-192620.png`: 233 bytes, 1-bit grayscale (blank screen)
- `screenshot-20250522-192853.png`: 233 bytes, 1-bit grayscale (blank screen)

The blank screenshots were taken when running VS Code, indicating that VS Code is not rendering properly in the virtual display.

## Solution

The solution involves several improvements to the virtual display configuration:

1. **Higher resolution and DPI settings**: Increasing the resolution to 1920x1080 and setting DPI to 96 provides a better environment for VS Code.

2. **Additional dependencies**: Installing additional graphics libraries that Electron/VS Code depends on.

3. **Environment variables**: Setting `LIBGL_ALWAYS_SOFTWARE=1` and `ELECTRON_DISABLE_GPU=1` to force software rendering.

4. **VS Code flags**: Running VS Code with `--disable-gpu` and `--disable-software-rasterizer` flags to improve compatibility with the virtual display.

## Files

- `fix-vscode-display.sh`: Script to fix VS Code rendering in the virtual display
- `run-with-xvfb-improved.sh`: Improved script to run commands with the virtual display
- `test-vscode-improved.sh`: Improved script to test VS Code with the virtual display

## Usage

1. Run the fix script to update the virtual display configuration:
   ```bash
   ./fix-vscode-display.sh
   ```

2. Use the improved script to run VS Code or other commands:
   ```bash
   ./run-with-xvfb-improved.sh code --version
   ```

3. Test VS Code with the improved configuration:
   ```bash
   ./test-vscode-improved.sh
   ```

## Verification

After applying the fix, check the new screenshot to verify that VS Code is rendering correctly. The new screenshot should be an 8-bit/color RGB image with a proper VS Code interface visible, not a blank 1-bit grayscale image.

## Troubleshooting

If VS Code still doesn't render correctly:

1. Check if all dependencies are installed:
   ```bash
   sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libgbm1
   ```

2. Try running VS Code with additional flags:
   ```bash
   DISPLAY=:1 LIBGL_ALWAYS_SOFTWARE=1 ELECTRON_DISABLE_GPU=1 code --disable-gpu --disable-software-rasterizer --no-sandbox
   ```

3. Check VS Code logs for errors:
   ```bash
   cat ~/.config/Code/logs/*/main.log | grep -i error