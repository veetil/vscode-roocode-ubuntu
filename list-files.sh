#!/bin/bash
# list-files.sh - List all files related to the Roo Code CLI with virtual display implementation

echo "Roo Code CLI with Virtual Display: Files"
echo "========================================"
echo

# Check for script files
echo "Script Files:"
for file in run-cli-with-xvfb.sh setup-xvfb-service.sh test-cli-with-xvfb.sh apply-cli-patch.sh; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file (missing)"
  fi
done
echo

# Check for documentation files
echo "Documentation Files:"
for file in README.md README-cli-with-xvfb.md vscode-virtual-display-research.md roocode-cli-virtual-display-summary.md; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file (missing)"
  fi
done
echo

# Check for patch files
echo "Patch Files:"
for file in cli-virtual-display.patch; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file (missing)"
  fi
done
echo

# Check for executable permissions
echo "Executable Permissions:"
for file in run-cli-with-xvfb.sh setup-xvfb-service.sh test-cli-with-xvfb.sh apply-cli-patch.sh; do
  if [ -x "$file" ]; then
    echo "✅ $file is executable"
  else
    if [ -f "$file" ]; then
      echo "❌ $file is not executable (run: chmod +x $file)"
    else
      echo "❌ $file is missing"
    fi
  fi
done
echo

# Check for Roo Code repository
echo "Roo Code Repository:"
if [ -d ~/LaunchRoo/Roo-Code ]; then
  echo "✅ Roo Code repository found at ~/LaunchRoo/Roo-Code"
else
  echo "❌ Roo Code repository not found at ~/LaunchRoo/Roo-Code"
fi
echo

# Check for CLI code
echo "CLI Code:"
if [ -f ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts ]; then
  echo "✅ CLI code found at ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts"
else
  echo "❌ CLI code not found at ~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts"
fi
echo

# Check for dependencies
echo "Dependencies:"
for cmd in xvfb-run Xvfb code pnpm; do
  if command -v $cmd &> /dev/null; then
    echo "✅ $cmd is installed"
  else
    echo "❌ $cmd is not installed"
  fi
done
echo

echo "All files have been checked."