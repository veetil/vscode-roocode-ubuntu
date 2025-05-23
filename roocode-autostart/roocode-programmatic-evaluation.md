# Deep Research: Roo-Code Programmatic Evaluation System

Based on my analysis of the Roo-Code repository, I've identified how the system programmatically evaluates code through the `pnpm cli python <expt>` command and what changes would be needed for an AWS Ubuntu instance.

## How the Programmatic Evaluation Works

### 1. Command Flow Architecture

The process follows these steps:

1. **CLI Command Execution**: When `pnpm cli python <expt>` is run:
   - The command is defined in `Roo-Code/evals/package.json` as `"cli": "turbo dev --filter @evals/cli -- run"`
   - This runs the CLI with arguments `python` (language) and `<expt>` (exercise name)

2. **Run Creation and Setup**:
   - The CLI (`Roo-Code/evals/apps/cli/src/index.ts`) processes these arguments
   - Creates a database run entry with a unique socket path
   - Sets up the exercise workspace and configuration

3. **VS Code Launch**:
   - The CLI launches VS Code with the Roo Code extension using:
   ```javascript
   await execa({
     env: { ROO_CODE_IPC_SOCKET_PATH: taskSocketPath },
     shell: "/bin/bash",
   })`code --disable-workspace-trust -n ${workspacePath}`
   ```

4. **IPC Communication Setup**:
   - The CLI creates an IPC (Inter-Process Communication) client that connects to the VS Code extension
   - The extension detects the socket path from environment variables and creates an IPC server

5. **Task Injection and Execution**:
   - The CLI sends a `StartNewTask` command with the prompt and configuration
   - The extension processes this command and starts a new task with the injected prompt
   - The AI agent in Roo Code processes the prompt and performs the task

6. **Event Monitoring and Completion**:
   - The CLI monitors task events (started, completed, aborted) via IPC
   - When the task is completed or times out, the CLI runs unit tests to verify the solution
   - Results are recorded in the database

### 2. Key Components

1. **IPC Communication**:
   - Uses Unix domain sockets for communication between CLI and VS Code
   - Implemented in `Roo-Code/evals/packages/ipc` and `Roo-Code/src/exports/ipc.ts`
   - Messages follow a structured schema defined in `Roo-Code/evals/packages/types/src/ipc.ts`

2. **VS Code Extension API**:
   - Implemented in `Roo-Code/src/exports/api.ts`
   - Handles task creation, monitoring, and event emission
   - Communicates with the CLI via IPC

3. **Task Processing**:
   - The extension uses `ClineProvider` to manage tasks
   - Tasks are processed by the AI agent in Roo Code
   - Events are emitted back to the CLI

## Mac-Specific Components and AWS Ubuntu Changes

### Mac-Specific Components

1. **Shell Commands**:
   - Uses `/bin/bash` explicitly in the CLI for launching VS Code
   - Some file path handling may be Mac-specific

2. **VS Code Launch**:
   - The command to launch VS Code may have Mac-specific behavior

### Changes Needed for AWS Ubuntu

1. **GUI Requirements**:
   - Roo Code **does require a GUI** as it launches VS Code with a graphical interface
   - For headless AWS Ubuntu, you'll need to set up X11 forwarding or a virtual display

2. **Display Setup Options**:
   - **X11 Forwarding**: Configure SSH with X11 forwarding to run VS Code remotely but display locally
   - **Virtual Display**: Use Xvfb (X Virtual Framebuffer) to create a virtual display on the AWS instance

3. **VS Code Installation**:
   - Install VS Code on Ubuntu using the appropriate package manager
   - Ensure the Roo Code extension is installed

4. **Path Adjustments**:
   - Update file paths in the code to use Linux-compatible paths
   - Ensure Unix socket paths are correctly set for Ubuntu

5. **Shell Compatibility**:
   - Verify shell commands work correctly on Ubuntu
   - Update any Mac-specific shell commands

## Implementation Plan for AWS Ubuntu

1. **Set Up Virtual Display**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y xvfb
   export DISPLAY=:1
   Xvfb :1 -screen 0 1024x768x24 > /dev/null 2>&1 &
   ```

2. **Install VS Code and Dependencies**:
   ```bash
   sudo apt-get install -y wget gpg apt-transport-https
   wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
   sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
   sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
   sudo apt-get update
   sudo apt-get install -y code
   ```

3. **Install Node.js and pnpm**:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   sudo npm install -g pnpm
   ```

4. **Clone and Set Up Roo-Code**:
   ```bash
   git clone https://github.com/your-repo/Roo-Code.git
   cd Roo-Code
   pnpm install
   ```

5. **Modify IPC Implementation**:
   - Update socket path handling to ensure compatibility with Ubuntu
   - Verify Unix socket permissions are correctly set

6. **Run with Virtual Display**:
   ```bash
   DISPLAY=:1 pnpm cli python <expt>
   ```

## Dockerization Considerations

For future dockerization:

1. **Container Setup**:
   - Use an Ubuntu-based image with X11 support
   - Install all dependencies (Node.js, pnpm, VS Code)
   - Set up a virtual display with Xvfb

2. **Example Dockerfile**:
   ```dockerfile
   FROM ubuntu:22.04
   
   # Install dependencies
   RUN apt-get update && apt-get install -y \
       wget gpg apt-transport-https \
       xvfb x11-utils \
       curl \
       git \
       && rm -rf /var/lib/apt/lists/*
   
   # Install Node.js and pnpm
   RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
       && apt-get install -y nodejs \
       && npm install -g pnpm
   
   # Install VS Code
   RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
       && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
       && sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' \
       && apt-get update \
       && apt-get install -y code
   
   # Set up virtual display
   ENV DISPLAY=:1
   
   # Clone and set up Roo-Code
   WORKDIR /app
   COPY . .
   RUN pnpm install
   
   # Start Xvfb and run the evaluation
   CMD Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \
       pnpm cli python $EXERCISE
   ```

3. **Volume Mounting**:
   - Mount exercise directories as volumes
   - Mount results directory to persist evaluation results

4. **Networking**:
   - Expose necessary ports if you need to access VS Code remotely
   - Consider using SSH tunneling for secure access