# Deep Research: Integrating Virtual Display with Roo Code CLI

## Overview

This research explores how to integrate the virtual display setup from `ubuntu_roocode_implementation` with the `pnpm cli python grep` command in the Roo-Code evaluation system. The goal is to enable headless execution of VS Code with the Roo Code extension activated through IPC, addressing several known issues.

## Current Implementations

### 1. VS Code with Virtual Display (`ubuntu_roocode_implementation`)

The `ubuntu_roocode_implementation` directory contains scripts for running VS Code with a virtual display using Xvfb. Key components include:

- **Virtual Display Setup**: Uses Xvfb to create a virtual display (`:1`) with specific parameters for VS Code compatibility
- **Environment Variables**: Sets `LIBGL_ALWAYS_SOFTWARE=1` and `ELECTRON_DISABLE_GPU=1` to improve rendering
- **VS Code Flags**: Uses `--disable-gpu`, `--disable-software-rasterizer`, and `--disable-workspace-trust` flags
- **Additional Dependencies**: Installs required graphics libraries for Electron/VS Code

Key scripts:
- `run-with-xvfb-improved.sh`: Runs commands with the virtual display
- `fix-vscode-display.sh`: Fixes VS Code rendering issues in the virtual display
- `test-vscode-improved.sh`: Tests VS Code with the virtual display

### 2. Roo Code CLI (`Roo-Code/evals/apps/cli`)

The CLI implementation in `Roo-Code/evals/apps/cli/src/index.ts` launches VS Code with the Roo Code extension and communicates with it via IPC. Key components include:

- **VS Code Launch**: Uses `execa` to launch VS Code with specific environment variables and flags
- **IPC Communication**: Sets up IPC communication between the CLI and VS Code extension
- **Task Execution**: Sends commands to the VS Code extension to start and monitor tasks
- **Unit Test Execution**: Runs unit tests to verify the solution

Current VS Code launch code:
```javascript
await execa({
  env: {
    ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,
    DISPLAY: process.env.DISPLAY || ":1", // Already using virtual display
    ELECTRON_ENABLE_SECURITY_WARNINGS: "false", // Disables OS keyring requirement
  },
  shell: "/bin/bash",
})`code --disable-workspace-trust --disable-keytar -n ${workspacePath}`
```

## Known Issues

1. **OS Keyring**: VS Code attempts to use the OS keyring for storing encryption-related data, which fails in headless environments
   - Current fix: Setting `ELECTRON_ENABLE_SECURITY_WARNINGS: "false"` and using `--disable-keytar` flag

2. **Workspace Trust**: VS Code shows a workspace trust popup that requires user interaction
   - Current fix: Using `--disable-workspace-trust` flag

3. **ServiceWorker Registration**: Error loading webview due to ServiceWorker registration failure
   - Current workaround: Clearing VS Code cache directories and restarting

4. **VS Code Terminal Integration**: Warning about command execution without VS Code terminal shell integration
   - No current fix implemented

## Integration Analysis

The current CLI implementation already includes some virtual display integration:
- Sets `DISPLAY: process.env.DISPLAY || ":1"` to use the virtual display
- Uses `--disable-workspace-trust` and `--disable-keytar` flags

However, it's missing some key components from the `ubuntu_roocode_implementation` scripts:
- Environment variables: `LIBGL_ALWAYS_SOFTWARE=1` and `ELECTRON_DISABLE_GPU=1`
- VS Code flags: `--disable-gpu` and `--disable-software-rasterizer`
- Xvfb configuration: Higher resolution, DPI settings, and extensions

## Integration Strategy

### 1. Xvfb Setup

The CLI should ensure Xvfb is running with the optimal configuration before launching VS Code:

```javascript
// Ensure Xvfb is running with optimal configuration
const ensureXvfb = async () => {
  // Kill existing Xvfb if running
  try {
    const xvfbPid = fs.existsSync('/tmp/xvfb.pid') ? 
      fs.readFileSync('/tmp/xvfb.pid', 'utf-8').trim() : null;
    if (xvfbPid) {
      await execa`kill ${xvfbPid}`;
      fs.unlinkSync('/tmp/xvfb.pid');
    }
  } catch (error) {
    console.log('Error stopping existing Xvfb:', error);
  }

  // Start Xvfb with improved configuration
  const display = ':1';
  const xvfbProcess = execa({
    detached: true,
    stdio: 'ignore',
  })`Xvfb ${display} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96`;
  
  fs.writeFileSync('/tmp/xvfb.pid', String(xvfbProcess.pid));
  xvfbProcess.unref();
  
  // Wait for Xvfb to initialize
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  return display;
};
```

### 2. VS Code Launch with Enhanced Environment

Update the VS Code launch code to include all necessary environment variables and flags:

```javascript
const display = await ensureXvfb();

await execa({
  env: {
    ROO_CODE_IPC_SOCKET_PATH: taskSocketPath,
    DISPLAY: display,
    ELECTRON_ENABLE_SECURITY_WARNINGS: "false",
    LIBGL_ALWAYS_SOFTWARE: "1",
    ELECTRON_DISABLE_GPU: "1",
  },
  shell: "/bin/bash",
})`code --disable-workspace-trust --disable-keytar --disable-gpu --disable-software-rasterizer -n ${workspacePath}`
```

### 3. Cache Clearing for ServiceWorker Issues

Add a function to clear VS Code cache directories when ServiceWorker issues occur:

```javascript
const clearVSCodeCache = async () => {
  const homeDir = os.homedir();
  const cacheDirs = [
    path.join(homeDir, '.config/Code/Cache'),
    path.join(homeDir, '.config/Code/CachedData'),
  ];
  
  for (const dir of cacheDirs) {
    if (fs.existsSync(dir)) {
      await execa`rm -rf ${dir}/*`;
    }
  }
};
```

### 4. Terminal Integration Warning

For the terminal integration warning, add a configuration option to disable the warning:

```javascript
// Create or update VS Code settings to disable terminal integration warning
const configureVSCode = async (workspacePath) => {
  const settingsDir = path.join(workspacePath, '.vscode');
  const settingsPath = path.join(settingsDir, 'settings.json');
  
  if (!fs.existsSync(settingsDir)) {
    fs.mkdirSync(settingsDir, { recursive: true });
  }
  
  let settings = {};
  if (fs.existsSync(settingsPath)) {
    settings = JSON.parse(fs.readFileSync(settingsPath, 'utf-8'));
  }
  
  settings['rooCode.terminal.suppressIntegrationWarning'] = true;
  
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
};
```

## Implementation Plan

1. **Create a Wrapper Script**: Develop a wrapper script that sets up the virtual display and launches the CLI

```bash
#!/bin/bash
# run-cli-with-xvfb.sh - Run the Roo Code CLI with virtual display

# Ensure Xvfb is running
if ! pgrep -x Xvfb > /dev/null; then
  echo "Starting Xvfb..."
  export DISPLAY=:1
  Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset -dpi 96 &
  echo $! > /tmp/xvfb.pid
  echo "Started Xvfb with PID $(cat /tmp/xvfb.pid)"
  sleep 3
fi

# Set environment variables
export DISPLAY=:1
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_DISABLE_GPU=1

# Clear VS Code cache if needed
if [ "$1" == "--clear-cache" ]; then
  echo "Clearing VS Code cache..."
  rm -rf ~/.config/Code/Cache/* ~/.config/Code/CachedData/*
  shift
fi

# Run the CLI command
echo "Running CLI command with virtual display: pnpm cli $@"
cd ~/LaunchRoo/Roo-Code/evals
pnpm cli "$@"
```

2. **Modify the CLI Code**: Update the CLI code to include the enhanced environment variables and flags

3. **Add Cache Clearing**: Implement cache clearing when ServiceWorker issues are detected

4. **Configure Terminal Integration**: Add settings to disable terminal integration warnings

## Compatibility Analysis

The integration strategy is compatible with both implementations:

1. **VS Code Launch**: Both implementations use similar approaches to launching VS Code
2. **Environment Variables**: The enhanced environment variables are compatible with both implementations
3. **Xvfb Configuration**: The improved Xvfb configuration works with both implementations
4. **IPC Communication**: The IPC communication is not affected by the virtual display setup

## Conclusion

Integrating the virtual display setup from `ubuntu_roocode_implementation` with the `pnpm cli python grep` command is feasible with minimal changes to the existing code. The key is to ensure that:

1. Xvfb is running with the optimal configuration
2. VS Code is launched with all necessary environment variables and flags
3. Cache clearing is implemented for ServiceWorker issues
4. Terminal integration warnings are suppressed

These changes will enable headless execution of VS Code with the Roo Code extension activated through IPC, addressing the known issues.

## Next Steps

1. Implement the wrapper script for testing
2. Modify the CLI code to include the enhanced environment variables and flags
3. Test the integration with the `pnpm cli python grep` command
4. Document the solution for future reference