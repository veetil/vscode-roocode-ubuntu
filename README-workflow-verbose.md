# RooCode Workflow Verbose Script

## Overview

The `workflow-verbose.sh` script provides a verbose interface for executing RooCode workflows with real CLI calls. It handles the entire workflow process from setting up the experiment folder to running the RooCode CLI with a virtual display, capturing test results, and reporting the outcome.

This script is built on top of the `roocode-modular.sh` framework and provides additional verbose logging and detailed output for debugging and monitoring purposes.

## Prerequisites

- Bash shell environment
- RooCode CLI installed
- Virtual display setup (Xvfb)
- `roocode-modular.sh` script in the same directory

## Usage

```bash
./workflow-verbose.sh --question "User question" --expt "experiment_folder" [OPTIONS]
```

## Required Arguments

- `--question "User question"`: The user question to save to question.md
- `--expt "experiment_folder"`: The experiment folder name (relative to /home/ubuntu/LaunchRoo/evals/python/)

## Optional Arguments

- `--prompt "Optional prompt"`: The prompt text to save to outline.md
- `--output "file1,folder1"`: A comma-separated list of files/folders to copy to the output folder
  - Use `*` to copy all files from the experiment folder
- `--session "session_id"`: The session ID for the output folder name (default: session_timestamp)
- `--files "source1:dest1,source2:dest2"`: A comma-separated list of source:destination file pairs
- `--timeout seconds`: Timeout in seconds for the CLI execution (default: 300)
- `--help`: Display help message

## Output

The script provides detailed logging with timestamps and log levels (INFO, DEBUG, ERROR, SUCCESS). It captures the output of the RooCode CLI execution and saves it to `/tmp/roocode-output.log`. The script also reports the test results and task completion status.

### Output Files

- `/tmp/roocode-output.log`: Contains the output of the RooCode CLI execution
- `/tmp/roocode-tests-passed.txt`: Contains "true" or "false" indicating if tests passed
- `/tmp/roocode-task-completed.txt`: Contains "true" or "false" indicating if the task completed

## Test Result Capture

The script captures test results by analyzing the output log file for specific patterns:

1. "taskEvent -> taskCompleted" pattern to determine if the task completed
2. "failed: 0" pattern to determine if tests passed

Tests are considered passed only if both conditions are met.

## Examples

### Basic Usage

```bash
./workflow-verbose.sh --question "What is the capital of France?" --expt "simple-qa"
```

### With Custom Prompt and Output

```bash
./workflow-verbose.sh --question "Create a React component for a login form" --expt "react-component" --prompt "Use Material UI" --output "component.jsx,README.md"
```

### With Extended Timeout

```bash
./workflow-verbose.sh --question "Do deep research on the latest announcements at Google I/O 2025" --expt "deep-research" --output "research.md" --timeout 1200
```

### Copy All Output Files

```bash
./workflow-verbose.sh --question "Create a full-stack web application" --expt "web-app" --output "*" --timeout 600
```

## Error Handling

The script includes robust error handling:

- Validates required arguments
- Checks for CLI execution failures
- Captures and reports test results
- Provides detailed error messages with log levels

If the RooCode CLI execution fails, the script will exit with a non-zero status code and display the error message.

## Integration with roocode-modular.sh

The `workflow-verbose.sh` script sources the `roocode-modular.sh` script to access its functions. It overrides the `run_roocode_cli` function with its own `run_roocode_cli_verbose` function to provide more detailed output.

The script uses the following functions from `roocode-modular.sh`:

- `execute_workflow`: Sets up the experiment folder
- `capture_branch_name`: Captures the Git branch name for the output folder
- `copy_output_files`: Copies the specified output files
- `capture_test_results`: Analyzes the output log to determine test results
- `commit_workflow_changes`: Commits the workflow changes to Git
- `report_results`: Reports the workflow results
- `cleanup`: Cleans up temporary files

## Workflow Steps

1. Parse command-line arguments
2. Set up the environment
3. Execute the workflow using `execute_workflow`
4. Run the RooCode CLI with verbose output using `run_roocode_cli_verbose`
5. Capture the branch name for the output folder
6. Copy output files if specified
7. Capture test results
8. Commit workflow changes
9. Report results
10. Clean up temporary files

## Logging

The script provides detailed logging with timestamps and log levels:

- `[INFO]`: General information about the workflow execution
- `[DEBUG]`: Detailed debugging information
- `[ERROR]`: Error messages
- `[SUCCESS]`: Success messages

## Exit Codes

- `0`: Workflow execution completed successfully
- `1`: An error occurred during workflow execution

## Troubleshooting

If the script fails, check the following:

1. Ensure the `roocode-modular.sh` script is in the same directory
2. Verify that the experiment folder exists
3. Check the output log file at `/tmp/roocode-output.log` for error messages
4. Ensure the virtual display (Xvfb) is set up correctly
5. Verify that the RooCode CLI is installed and configured properly

## Advanced Usage

### Custom Session ID

```bash
./workflow-verbose.sh --question "Analyze this dataset" --expt "data-analysis" --session "custom_session_123"
```

### Custom File Mapping

```bash
./workflow-verbose.sh --question "Translate this document" --expt "translation" --files "source.txt:input.txt,config.json:settings.json"
```

### Combining Multiple Options

```bash
./workflow-verbose.sh --question "Build a machine learning model" --expt "ml-model" --prompt "Use TensorFlow" --output "model.py,README.md" --timeout 900 --session "ml_session_1"