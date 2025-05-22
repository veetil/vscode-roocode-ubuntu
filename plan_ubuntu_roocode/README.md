# Porting Roo Code to Ubuntu AWS

This repository contains a comprehensive plan for porting the Roo Code autostart functionality from macOS to Ubuntu running on AWS instances.

## Overview

Roo Code is a VS Code extension that uses AI to assist with coding tasks. The autostart functionality allows programmatic evaluation of code through the `pnpm cli python <expt>` command. This plan outlines the steps needed to make this functionality work on Ubuntu AWS instances.

## Key Challenges

1. **GUI Requirements**: Roo Code requires a graphical interface as it launches VS Code with a GUI. On a headless AWS Ubuntu instance, this requires setting up a virtual display environment.

2. **VS Code Launch**: The command to launch VS Code may have Mac-specific behavior that needs to be adapted for Ubuntu.

3. **IPC Communication**: The system uses Unix domain sockets for communication between the CLI and VS Code extension, which may require adjustments for Ubuntu.

4. **Process Management**: The system uses `ps-tree` for process management, which might behave differently on Ubuntu.

5. **Remote Access**: Since we're running on a remote AWS instance, we need to provide ways to access the VS Code UI for debugging and monitoring.

## Plan Structure

The plan is divided into the following documents:

1. [**Mac-Specific Components**](1.md): Identifies the Mac-specific components in the Roo Code autostart functionality.

2. [**Virtual Display Setup**](2.md): Provides instructions for setting up a virtual display environment using Xvfb on Ubuntu.

3. [**VS Code and Dependencies Installation**](3.md): Outlines the steps to install VS Code and all required dependencies on Ubuntu.

4. [**CLI Modifications**](4.md): Details the changes needed in the Roo Code CLI to work with the virtual display on Ubuntu.

5. [**Remote Access Setup**](5.md): Provides options for remotely accessing the VS Code UI running on the AWS instance.

6. [**Implementation and Testing Plan**](6.md): Presents a step-by-step approach to implement and test the changes.

## Implementation Strategy

The implementation strategy follows these key principles:

1. **Incremental Changes**: Make small, targeted changes and test them thoroughly before moving on.

2. **Minimal Modifications**: Modify only what's necessary to make the system work on Ubuntu, preserving the original functionality.

3. **Robust Error Handling**: Add comprehensive error handling to diagnose and recover from issues specific to the Ubuntu environment.

4. **Flexible Configuration**: Use environment variables to allow configuration of Ubuntu-specific settings without modifying the code.

5. **Comprehensive Testing**: Test each component individually and then the entire system to ensure everything works correctly.

## Key Components

### 1. Virtual Display with Xvfb

Xvfb (X Virtual Framebuffer) creates a virtual display on the AWS instance, allowing VS Code to run without a physical display.

```bash
export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
```

### 2. VS Code Launch Command

The VS Code launch command needs to be modified to use the virtual display:

```javascript
await execa({
  env: {
    ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,
    DISPLAY: process.env.DISPLAY || ":1", // Use the virtual display
  },
  shell: "/bin/bash",
})`code --disable-workspace-trust -n ${workspacePath}`
```

### 3. IPC Communication

The IPC communication uses Unix domain sockets, which need to be adjusted for Ubuntu:

```javascript
const tmpDir = process.env.XDG_RUNTIME_DIR || os.tmpdir();
const socketPath = path.resolve(tmpDir, `roo-code-evals-${crypto.randomUUID().slice(0, 8)}.sock`);
```

### 4. Remote Access Options

Several options are provided for remote access to the VS Code UI:

1. **SSH Tunneling with X11 Forwarding**: Forward the X11 display from the AWS instance to your local machine.
2. **VNC Server**: Provide a full desktop environment that you can access remotely.
3. **VS Code Remote SSH Extension**: Use VS Code's built-in Remote SSH extension to connect to the AWS instance.
4. **Code Server**: Run VS Code in a browser using code-server.
5. **AWS EC2 Instance Connect Endpoint**: Use EC2 Instance Connect Endpoint for secure browser-based SSH access.

## Getting Started

To implement this plan, follow these steps:

1. Set up an Ubuntu 22.04 LTS instance on AWS.
2. Follow the step-by-step instructions in [Implementation and Testing Plan](6.md).
3. Test the implementation with a simple exercise.
4. Set up remote access if needed using the options in [Remote Access Setup](5.md).

## Troubleshooting

Common issues and their solutions are documented in each section. If you encounter problems:

1. Check the logs for error messages.
2. Verify that Xvfb is running correctly.
3. Ensure VS Code is installed and can be launched from the command line.
4. Check the IPC socket path and permissions.
5. Increase timeouts if needed for slower AWS instances.

## Future Improvements

1. **Dockerization**: Create a Docker container with all the necessary components pre-installed.
2. **Automated Testing**: Set up automated tests to verify the functionality on Ubuntu.
3. **Performance Optimization**: Optimize the virtual display settings for better performance.
4. **Security Hardening**: Implement additional security measures for running in a cloud environment.
5. **Multi-Platform Support**: Extend the implementation to support other Linux distributions.