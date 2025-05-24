# Roo Code CLI with Virtual Display

This repository contains scripts and documentation for running the Roo Code CLI with a virtual display in headless environments.

## Table of Contents

- [Overview](#overview)
- [Files and Components](#files-and-components)
- [Installation](#installation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [RooCode Modular Workflow](#roocode-modular-workflow)
  - [Output Files Feature](#output-files-feature)
- [Documentation](#documentation)
- [Testing](#testing)
- [Contributing](#contributing)

## Overview

The Roo Code CLI (`pnpm cli python grep`) launches VS Code with the Roo Code extension and activates it using an IPC interface. In headless environments, VS Code requires a virtual display to function correctly. This implementation provides solutions for running the CLI with a virtual display, addressing common issues such as OS keyring prompts, workspace trust popups, and rendering problems.

## Files and Components

| File | Description |
|------|-------------|
| `README.md` | This file |
| `run-cli-with-xvfb.sh` | Wrapper script to run the CLI with a virtual display |
| `setup-xvfb-service.sh` | Script to set up Xvfb as a systemd service |
| `test-cli-with-xvfb.sh` | Script to test the CLI with a virtual display |
| `apply-cli-patch.sh` | Script to apply the CLI patch |
| `cli-virtual-display.patch` | Patch for the CLI code to incorporate virtual display improvements |
| `README-cli-with-xvfb.md` | Detailed README for the wrapper script |
| `vscode-virtual-display-research.md` | Comprehensive research document |
| `roocode-cli-virtual-display-summary.md` | Summary of the implementation |
| `roocode-modular.sh` | Enhanced RooCode CLI workflow script |
| `test-input-processing.sh` | Test script for input processing functionality |
| `test-file-management.sh` | Test script for file management functionality |
| `test-git-operations.sh` | Test script for git operations functionality |
| `test-workflow-execution.sh` | Test script for workflow execution functionality |
| `test-output-files.sh` | Test script for output files functionality |
| `test-output-all-files.sh` | Test script for the `--output "*"` feature |
| `test-end-to-end.sh` | End-to-end test script for the entire system |
| `test-all.sh` | Script to run all tests |
| `USER_GUIDE.md` | Comprehensive user guide for the RooCode Modular System |
| `DEVELOPER_GUIDE.md` | Guide for developers who want to extend or modify the system |
| `TROUBLESHOOTING.md` | Detailed troubleshooting guide |
| `EXAMPLES.md` | Examples of how to use the RooCode Modular System |
| `README-output-files.md` | Documentation for the output files feature |
| `README-output-all-files.md` | Documentation for the `--output "*"` feature |

## Installation

### Prerequisites

- Ubuntu Linux (or compatible distribution)
- Node.js and pnpm installed
- Roo Code repository cloned

### Installing Dependencies

```bash
# Install Xvfb and related packages
sudo apt-get update
sudo apt-get install -y xvfb x11-utils x11-apps imagemagick

# Install additional dependencies for VS Code rendering
# Note: Some packages might not be available in all Ubuntu versions
# The scripts will continue even if some packages cannot be installed

# These packages are usually available in most Ubuntu versions
for pkg in libxrandr2 libxss1 libxcursor1 libxcomposite1 libxi6 libxtst6 libgbm1; do
  sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done

# These packages might not be available in all Ubuntu versions
for pkg in libgl1-mesa-glx libegl1-mesa libasound2; do
  sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done
```

### Setting Up Xvfb as a Service (Optional)

```bash
./setup-xvfb-service.sh
```

### Applying the CLI Patch (Optional)

```bash
./apply-cli-patch.sh
```

## Usage

### Using the Wrapper Script

The simplest way to run the CLI with a virtual display is to use the wrapper script:

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

### Taking a Screenshot

To verify that VS Code is rendering correctly, you can take a screenshot:

```bash
./run-cli-with-xvfb.sh --screenshot python grep
```

### Testing the Implementation

To test the implementation:

```bash
./test-cli-with-xvfb.sh
```

## Troubleshooting

### VS Code Doesn't Launch

If VS Code doesn't launch, check:

1. VS Code installation: `which code`
2. Xvfb process: `ps aux | grep Xvfb`
3. DISPLAY environment variable: `echo $DISPLAY`

### Blank or Corrupted Display

If VS Code launches but shows a blank or corrupted display:

1. Try clearing the VS Code cache: `./run-cli-with-xvfb.sh --clear-cache python grep`
2. Check if all dependencies are installed (note that some packages like `libgl1-mesa-glx`, `libegl1-mesa`, and `libasound2` might not be available in all Ubuntu versions)
3. Verify Xvfb configuration: `xdpyinfo | grep "dimensions"`

### Terminal Integration Warning

If you see a warning about VS Code terminal integration:

1. This warning is informational and doesn't affect functionality
2. You can disable it in the Roo Code extension settings

### ServiceWorker Registration Errors

If you see ServiceWorker registration errors:

1. Clear VS Code cache: `rm -rf ~/.config/Code/Cache/* ~/.config/Code/CachedData/*`
2. Kill any running VS Code processes: `killall code`
3. Try running the command again

## Advanced Configuration

### Modifying the Wrapper Script

You can modify the `run-cli-with-xvfb.sh` script to:

1. Change the display number (default: `:1`)
2. Adjust the screen resolution (default: `1920x1080x24`)
3. Add additional VS Code flags
4. Modify environment variables

### Modifying the CLI Patch

You can modify the `cli-virtual-display.patch` file to:

1. Add additional environment variables
2. Add additional VS Code flags
3. Modify the CLI code in other ways

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## RooCode Modular Workflow

The `roocode-modular.sh` script provides an enhanced workflow for running RooCode CLI experiments. It includes features for:

1. Processing input parameters (question, experiment name, files, etc.)
2. Managing files (copying files to experiment folder)
3. Handling git operations (creating branches, committing changes)
4. Executing the RooCode workflow
5. Preserving output files (copying files to output folder)

The system is designed to be modular, extensible, and well-tested. It includes:

- Comprehensive documentation (USER_GUIDE.md, DEVELOPER_GUIDE.md, TROUBLESHOOTING.md, EXAMPLES.md)
- Extensive test suite (test-*.sh scripts)
- End-to-end testing (test-end-to-end.sh)
- Consolidated test runner (test-all.sh)

### Output Files Feature

The output files feature allows you to specify files and folders from the experiment directory that should be copied to a dedicated output folder. This is useful for preserving important outputs from your experiments.

#### Basic Usage

```bash
./roocode-modular.sh \
    --question "Your question" \
    --expt "experiment_name" \
    --output "file1.txt,folder1,subfolder/file2.py" \
    --session "unique_session_id"
```

#### Copying All Files

To copy the entire experiment folder contents recursively, use the special value `*` for the `--output` parameter:

```bash
./roocode-modular.sh \
    --question "Your question" \
    --expt "experiment_name" \
    --output "*" \
    --session "unique_session_id"
```

For more detailed information about the output files feature, please refer to:

- `README-output-files.md`: Documentation for the output files feature
- `README-output-all-files.md`: Documentation for the `--output "*"` feature

## Documentation

The RooCode Modular System includes comprehensive documentation:

- `USER_GUIDE.md`: A detailed guide for users of the system, including installation, usage, and examples
- `DEVELOPER_GUIDE.md`: A guide for developers who want to extend or modify the system
- `TROUBLESHOOTING.md`: A detailed troubleshooting guide with solutions to common issues
- `EXAMPLES.md`: A collection of examples demonstrating how to use the system for various scenarios

## Testing

The RooCode Modular System includes a comprehensive test suite:

- `test-input-processing.sh`: Tests the input processing component
- `test-file-management.sh`: Tests the file management component
- `test-git-operations.sh`: Tests the git operations component
- `test-workflow-execution.sh`: Tests the workflow execution component
- `test-output-files.sh`: Tests the output files feature
- `test-output-all-files.sh`: Tests the output all files feature
- `test-end-to-end.sh`: Tests the entire system end-to-end
- `test-all.sh`: Runs all tests

To run all tests:

```bash
./test-all.sh
```

To run a specific test:

```bash
./test-input-processing.sh
```

## Additional Resources

For more detailed information, please refer to:

- `README-cli-with-xvfb.md`: Detailed README for the wrapper script
- `vscode-virtual-display-research.md`: Comprehensive research document
- `roocode-cli-virtual-display-summary.md`: Summary of the implementation
- `README-output-files.md`: Documentation for the output files feature
- `README-output-all-files.md`: Documentation for the `--output "*"` feature
- `USER_GUIDE.md`: Comprehensive user guide for the RooCode Modular System
- `DEVELOPER_GUIDE.md`: Guide for developers who want to extend or modify the system
- `TROUBLESHOOTING.md`: Detailed troubleshooting guide
- `EXAMPLES.md`: Examples of how to use the RooCode Modular System