# RooCode Modular System Research

## Current RooCode Launch Process Analysis

### Overview

Currently, RooCode is launched with VSCode using a script called `run-cli-with-xvfb.sh`. The script takes two arguments:
1. The language (e.g., "python")
2. The experiment folder name (e.g., "grep")

The experiment folder is located at `/home/ubuntu/LaunchRoo/evals/python/grep` in this example.

### Process Flow

1. The script starts a virtual X display using Xvfb
2. It then launches VSCode with the RooCode extension
3. RooCode interacts with the experiment folder, which contains:
   - Test files
   - Implementation files
   - Documentation
4. RooCode creates a new branch, makes changes, and commits them
5. The workflow concludes with test results and the name of the new branch

### Git Operations

The current process involves several git operations:
1. The remote for `/home/ubuntu/LaunchRoo/evals` is `github.com/cte/eval` or similar
2. The process removes this remote
3. It performs a `git checkout main` to ensure it's on the local main branch
4. It updates the local main branch with the experiment files
5. During the workflow, a new branch is created
6. Changes are committed to this new branch

## Requirements for the Modular System

### Input Requirements

The modular system needs to accept the following inputs:

1. **User Question**
   - This text will be copied to `question.md` in the experiment folder
   - Path: `/home/ubuntu/LaunchRoo/evals/python/<expt>/question.md`

2. **Experiment Folder Name**
   - This may be an existing folder or a new one
   - Path: `/home/ubuntu/LaunchRoo/evals/python/<expt>/`

3. **List of Files (Optional)**
   - For each file, a source path and destination relative path are provided
   - Files are copied to the experiment folder
   - Format: `<source>/file.xyz /home/ubuntu/LaunchRoo/evals/python/<expt>/<destination relative path or empty>/file.xyz`

4. **Prompt (Optional)**
   - If provided, this text is copied to `outline.md` in the experiment folder
   - Path: `/home/ubuntu/LaunchRoo/evals/python/<expt>/outline.md`

### Process Requirements

The modular system needs to:

1. **Handle Git Operations**
   - Remove the remote if it exists
   - Checkout the local main branch
   - Update the local main branch with the experiment files
   - Allow RooCode to create a new branch and commit changes

2. **Launch RooCode**
   - Use the `run-cli-with-xvfb.sh` script
   - Pass the language and experiment folder name

3. **Report Results**
   - Print whether tests passed
   - Print the name of the new branch created

### Docker Requirements

The Docker implementation needs to:

1. **Accept Inputs**
   - Accept the same inputs as the modular system
   - Handle file copying within the container

2. **Set Up Environment**
   - Set up a virtual X display
   - Clone and configure RooCode
   - Set up git

3. **Execute Workflow**
   - Run the RooCode workflow within the container
   - Capture the output

4. **Report Results**
   - Report results back to the host system
   - Provide detailed logs and reports

## Analysis of Key Components

### Virtual Display Setup

The current process uses Xvfb to create a virtual X display. This is necessary because RooCode launches VSCode, which requires a display. In a Docker container, we'll need to:

1. Install Xvfb
2. Configure it correctly
3. Set the `DISPLAY` environment variable

### Git Operations

The git operations are critical to the workflow. We need to:

1. Initialize a git repository if it doesn't exist
2. Configure git user information
3. Remove the remote if it exists
4. Checkout the main branch
5. Add and commit the experiment files

### RooCode Launch

Launching RooCode involves:

1. Using the `run-cli-with-xvfb.sh` script
2. Passing the language and experiment folder name
3. Capturing the output

### Result Reporting

Result reporting involves:

1. Parsing the output to determine if tests passed
2. Extracting the name of the new branch
3. Formatting and presenting the results

## Technical Challenges and Solutions

### Challenge 1: Virtual Display in Docker

Running a graphical application like VSCode in a Docker container requires a virtual display.

**Solution**: Use Xvfb to create a virtual display and set the `DISPLAY` environment variable.

### Challenge 2: Git Operations in Docker

Git operations in a Docker container can be tricky, especially when dealing with repositories and branches.

**Solution**: Use git commands with proper error handling and ensure the git configuration is set correctly.

### Challenge 3: File Copying

Copying files from the host to the container and within the container requires careful handling.

**Solution**: Use volume mounts to share files between the host and container, and use `cp` commands with proper error handling.

### Challenge 4: Output Parsing

Parsing the output of the RooCode workflow to extract test results and branch name requires careful handling.

**Solution**: Use grep and other text processing tools to extract the relevant information from the output.

## Conclusion

The RooCode modular system requires careful handling of inputs, git operations, and result reporting. The Docker implementation adds additional challenges related to the container environment, but these can be addressed with proper configuration and error handling.

The research provides a solid foundation for the implementation plan, which will be divided into multiple steps to ensure a robust and maintainable solution.