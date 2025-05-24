# Research: RooCode Modular Workflow System

## Current System Analysis

The current RooCode workflow system operates as follows:

1. **Launch Command**: `./run-cli-with-xvfb.sh python grep`
   - Uses a virtual display (Xvfb) to run VS Code headlessly
   - Takes language (`python`) and experiment folder (`grep`) as parameters

2. **Command Flow**:
   - The script starts Xvfb if not already running
   - Sets the DISPLAY environment variable
   - Runs the specified command with the virtual display
   - The CLI command is defined in `Roo-Code/evals/package.json` as `"cli": "turbo dev --filter @evals/cli -- run"`

3. **VS Code Launch Process**:
   - CLI processes arguments and sets up exercise workspace
   - Launches VS Code with the Roo Code extension
   - Uses IPC to communicate between CLI and VS Code extension
   - Injects task and monitors events
   - Runs unit tests to verify solution when task is completed

4. **File Structure**:
   - Experiments are organized in `/home/ubuntu/LaunchRoo/evals/python/[experiment_name]/`
   - Each experiment folder contains test files, implementation files, and documentation

## Required Modifications

The new system needs to:

1. **Handle User Questions**:
   - Accept user question text
   - Save to `question.md` in the experiment folder

2. **Manage Experiment Folders**:
   - Case 1: Use existing folder in `/home/ubuntu/LaunchRoo/evals/python/`
   - Case 2: Create new folder if it doesn't exist

3. **Copy Optional Files**:
   - Accept a list of files with source and destination paths
   - Copy each file to the appropriate location in the experiment folder

4. **Handle Optional Prompts**:
   - Accept optional prompt text
   - Save to `outline.md` in the experiment folder

5. **Git Operations**:
   - Remove remote for `/home/ubuntu/LaunchRoo/evals` if it exists
   - Keep `git checkout main` operation
   - Update local main branch with created files
   - Create a new branch during workflow execution
   - Commit changes to the new branch

6. **Workflow Execution and Reporting**:
   - Execute the workflow using the existing system
   - Report if tests passed
   - Report the name of the new branch created

## Technical Considerations

1. **Virtual Display**:
   - The current system uses Xvfb to create a virtual display
   - This is necessary for running VS Code headlessly
   - The improved script includes optimizations for VS Code rendering

2. **IPC Communication**:
   - The system uses Unix domain sockets for communication between CLI and VS Code
   - Socket paths need to be correctly set for the environment

3. **Git Operations**:
   - Need to handle git operations carefully to maintain repository integrity
   - Need to ensure operations are performed in the correct order

4. **Docker Considerations**:
   - The system will eventually run in a Docker container
   - Need to ensure all operations are compatible with containerization
   - Input parameters will be provided to the Docker container

## Implementation Challenges

1. **File Path Management**:
   - Need to handle relative and absolute paths correctly
   - Need to ensure destination directories exist before copying files

2. **Git Remote Management**:
   - Need to check if remote exists before attempting to remove it
   - Need to handle potential errors during git operations

3. **Branch Creation and Tracking**:
   - Need to capture the name of the new branch created during workflow execution
   - Need to ensure branch name is reported correctly at the end

4. **Error Handling**:
   - Need robust error handling for all operations
   - Need to provide clear error messages for troubleshooting

5. **Testing Strategy**:
   - Need to test each component individually
   - Need to test the entire workflow end-to-end
   - Need to verify that all files are created correctly
   - Need to verify that git operations are performed correctly
   - Need to verify that the workflow executes correctly
   - Need to verify that test results and branch name are reported correctly

## Conclusion

The modifications required to the current RooCode workflow system are significant but achievable. By breaking down the implementation into modular components and testing each step thoroughly, we can create a robust system that meets all requirements and is compatible with future containerization.