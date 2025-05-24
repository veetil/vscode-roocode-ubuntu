# VS Code with Virtual Display Research

## Introduction

This document explores the implementation of VS Code with a virtual display for the Roo Code CLI. It covers the challenges, solutions, and technical details of running VS Code in a headless environment.

## Background

The Roo Code CLI (`pnpm cli python grep`) launches VS Code with the Roo Code extension and activates it using an IPC interface. In headless environments, VS Code requires a virtual display to function correctly. This research document explores the implementation details and solutions to common issues.

## Roo-Code CLI Implementation

### CLI Code Structure

The CLI code is located in `~/LaunchRoo/Roo-Code/evals/apps/cli/src/index.ts`. This file contains the logic for launching VS Code with the Roo Code extension and activating it using an IPC interface.

Key components of the CLI code:

1. **Command-line argument parsing**: The CLI parses arguments to determine which language and exercise to run.
2. **VS Code launch**: The CLI launches VS Code with specific arguments and environment variables.
3. **IPC interface**: The CLI communicates with the Roo Code extension using an IPC interface.

### VS Code Launch Process

The VS Code launch process in the CLI code involves:

1. Determining the workspace path based on the language and exercise.
2. Setting up environment variables for VS Code.
3. Launching VS Code with specific arguments.
4. Waiting for the Roo Code extension to activate.

## Common Issues

### OS Keyring

VS Code attempts to use the OS keyring to store encryption-related data. In headless environments, this can cause issues because there is no OS keyring available.

**Solution**: Disable the OS keyring requirement by setting the `ELECTRON_ENABLE_SECURITY_WARNINGS` environment variable to `false`.

```typescript
ELECTRON_ENABLE_SECURITY_WARNINGS: "false"
```

### Workspace Trust Popup

VS Code shows a workspace trust popup when opening a workspace for the first time. This can block the CLI from proceeding.

**Solution**: Disable workspace trust by adding the `--disable-workspace-trust` flag to the VS Code launch command.

```typescript
code --disable-workspace-trust --disable-keytar -n ${workspacePath}
```

### ServiceWorker Registration Errors

VS Code uses ServiceWorkers for various features. In headless environments, ServiceWorker registration can fail with the error:

```
Error loading webview: Error: Could not register service worker: InvalidStateError: Failed to register a ServiceWorker: The document is in an invalid state.
```

**Solution**: Clear the VS Code cache before launching VS Code.

```bash
rm -rf ~/.config/Code/Cache/*
rm -rf ~/.config/Code/CachedData/*
```

### VS Code Terminal Integration

The Roo Code extension shows a warning when commands are executed without VS Code terminal shell integration:

```
Your command is being executed without VSCode terminal shell integration. To suppress this warning you can disable shell integration in the Terminal section of the Roo Code settings.
```

**Solution**: This warning is informational and doesn't affect functionality. It can be disabled in the Roo Code extension settings.

## Virtual Display Implementation

### Xvfb (X Virtual Frame Buffer)

Xvfb is a virtual X server that can run on machines with no display hardware and no physical input devices. It's the primary tool used to create a virtual display for VS Code.

**Basic Xvfb setup**:

```bash
Xvfb :1 -screen 0 1920x1080x24 -ac &
export DISPLAY=:1
```

### Xvfb Configuration

Optimal Xvfb configuration for VS Code:

```bash
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
```

Key options:
- `:1`: Display number
- `-screen 0 1920x1080x24`: Screen resolution and color depth
- `-ac`: Disable access control (allows any client to connect)
- `+extension GLX`: Enable GLX extension (required for hardware acceleration)
- `+render`: Enable the Render extension
- `-noreset`: Don't reset the X server when the last client disconnects

### Environment Variables

Important environment variables for VS Code with a virtual display:

```bash
export DISPLAY=:1
export ELECTRON_ENABLE_SECURITY_WARNINGS=false
export ELECTRON_NO_ATTACH_CONSOLE=1
export ELECTRON_NO_SANDBOX=1
```

## Implementation Approaches

### Wrapper Script

The simplest approach is to use a wrapper script that:

1. Sets up Xvfb
2. Configures environment variables
3. Runs the CLI command
4. Cleans up Xvfb

**Advantages**:
- No code changes required
- Simple to implement
- Can be used with any version of the CLI

**Disadvantages**:
- Requires running a separate script
- Not integrated with the CLI

### CLI Code Modification

A more integrated approach is to modify the CLI code to:

1. Check if running in a headless environment
2. Set up Xvfb if needed
3. Configure environment variables
4. Run the CLI command
5. Clean up Xvfb

**Advantages**:
- Integrated with the CLI
- No separate script required
- Can be more robust

**Disadvantages**:
- Requires code changes
- More complex to implement

### Systemd Service

A system-wide approach is to set up Xvfb as a systemd service:

1. Create a systemd service file for Xvfb
2. Start the service
3. Configure environment variables
4. Run the CLI command

**Advantages**:
- System-wide solution
- No need to start/stop Xvfb for each CLI run
- Can be more efficient

**Disadvantages**:
- Requires systemd
- More complex to set up
- May require root access

## Compatibility Considerations

### Ubuntu Versions

Different Ubuntu versions may have different package availability. For example, `libgl1-mesa-glx`, `libegl1-mesa`, and `libasound2` might not be available in all Ubuntu versions.

**Solution**: Install packages one by one and continue even if some are not available.

```bash
for pkg in libgl1-mesa-glx libegl1-mesa libasound2; do
  sudo apt-get install -y $pkg || echo "Warning: Package $pkg could not be installed, continuing anyway..."
done
```

### VS Code Versions

Different VS Code versions may have different requirements and behavior. The solutions described in this document have been tested with VS Code 1.60.0 and later.

## Conclusion

Running VS Code with a virtual display in headless environments requires addressing several challenges, including OS keyring issues, workspace trust popups, and ServiceWorker registration errors. The solutions described in this document provide a robust approach to running the Roo Code CLI in headless environments.

## References

- [Xvfb Documentation](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
- [VS Code Command Line Interface](https://code.visualstudio.com/docs/editor/command-line)
- [Electron Environment Variables](https://www.electronjs.org/docs/latest/api/environment-variables)