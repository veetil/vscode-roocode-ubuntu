#!/bin/bash
# apply-cli-patch.sh - Apply the CLI patch to incorporate virtual display improvements

set -e  # Exit immediately if a command exits with a non-zero status

echo "Applying CLI patch to incorporate virtual display improvements..."

# Check if the Roo Code repository exists
if [ ! -d ~/LaunchRoo/Roo-Code ]; then
  echo "Error: Roo Code repository not found at ~/LaunchRoo/Roo-Code"
  exit 1
fi

# Check if the CLI code exists
if [ ! -f ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts ]; then
  echo "Error: CLI code not found at ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts"
  exit 1
fi

# Check if the patch file exists
if [ ! -f ~/LaunchRoo/cli-virtual-display.patch ]; then
  echo "Error: Patch file not found at ~/LaunchRoo/cli-virtual-display.patch"
  exit 1
fi

# Create a backup of the original file
echo "Creating backup of original file..."
cp ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts.bak
echo "Backup created at ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts.bak"

# Apply the patch
echo "Applying patch..."
cd ~/LaunchRoo/Roo-Code
git apply ~/LaunchRoo/cli-virtual-display.patch

# Check if the patch was applied successfully
if [ $? -eq 0 ]; then
  echo "Patch applied successfully."
else
  echo "Error: Failed to apply patch."
  echo "Restoring backup..."
  cp ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts.bak ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts
  exit 1
fi

# Build the CLI
echo "Building the CLI..."
cd ~/LaunchRoo/Roo-Code/evals
pnpm build

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo "Build successful."
else
  echo "Error: Failed to build the CLI."
  echo "Restoring backup..."
  cp ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts.bak ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts
  exit 1
fi

echo "CLI patch has been applied successfully."
echo "You can now run the CLI with: pnpm cli python grep"