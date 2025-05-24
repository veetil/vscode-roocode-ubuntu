# RooCode Modular System Developer Guide

## Introduction

This guide is intended for developers who want to extend or modify the RooCode Modular System. It provides an overview of the system architecture, components, and guidelines for development.

## System Architecture

The RooCode Modular System is designed with a modular architecture, consisting of the following components:

1. **Input Processing**: Handles command-line arguments and validates inputs
2. **Experiment Folder Management**: Creates and manages experiment folders
3. **File Management**: Handles file operations such as saving questions, prompts, and copying files
4. **Git Operations**: Manages git operations for the experiment
5. **Workflow Execution**: Executes the RooCode workflow and captures results
6. **Output Management**: Handles copying files to the output directory

Each component is implemented as a set of functions in the main script (`roocode-modular.sh`).

## Code Organization

The main script (`roocode-modular.sh`) is organized into sections for each component:

```bash
#!/bin/bash
# roocode-modular.sh - Enhanced RooCode CLI workflow

# Constants
# ...

# Input Processing
# ...

# Experiment Folder Management
# ...

# File Management
# ...

# Git Operations
# ...

# Workflow Execution
# ...

# Output Management
# ...

# Main function
# ...

# Execute main function
# ...
```

Each component has its own set of functions that handle specific tasks.

## Testing

The system includes a comprehensive test suite:

- `test-input-processing.sh`: Tests the input processing component
- `test-file-management.sh`: Tests the file management component
- `test-git-operations.sh`: Tests the git operations component
- `test-workflow-execution.sh`: Tests the workflow execution component
- `test-output-files.sh`: Tests the output files feature
- `test-output-all-files.sh`: Tests the output all files feature
- `test-end-to-end.sh`: Tests the entire system end-to-end
- `test-all.sh`: Runs all tests

When making changes to the system, make sure to run the appropriate tests to ensure that your changes don't break existing functionality.

## Adding New Features

To add a new feature to the system, follow these steps:

1. **Identify the component**: Determine which component the feature belongs to
2. **Implement the feature**: Add the necessary functions to the component
3. **Update the main function**: Add calls to the new functions in the main function
4. **Add tests**: Create tests for the new feature
5. **Update documentation**: Update the user guide and developer guide

### Example: Adding a New Command-Line Option

Let's say you want to add a new command-line option `--verbose` to enable verbose output:

1. **Identify the component**: This belongs to the Input Processing component
2. **Implement the feature**:

```bash
# Add to the parse_arguments function
function parse_arguments {
  # ...
  VERBOSE=false
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      # ...
      --verbose)
        VERBOSE=true
        shift
        ;;
      # ...
    esac
  done
}

# Add to the display_usage function
function display_usage {
  # ...
  echo "  --verbose   Enable verbose output (optional)"
  # ...
}
```

3. **Update the main function**: No changes needed for this example
4. **Add tests**: Update `test-input-processing.sh` to test the new option
5. **Update documentation**: Update the user guide and developer guide

## Modifying Existing Features

When modifying existing features, follow these guidelines:

1. **Understand the current implementation**: Make sure you understand how the feature currently works
2. **Make minimal changes**: Only change what's necessary to implement the new behavior
3. **Run tests**: Run the appropriate tests to ensure that your changes don't break existing functionality
4. **Update documentation**: Update the user guide and developer guide

## Best Practices

### Error Handling

The system uses a consistent error handling approach:

```bash
if [ condition ]; then
  echo "Error: Error message"
  exit 1
fi
```

When adding new code, follow this pattern for error handling.

### Logging

The system uses echo statements for logging:

```bash
echo "Message"
```

For verbose logging, use:

```bash
if [ "${VERBOSE}" = true ]; then
  echo "Verbose message"
fi
```

### Function Documentation

Each function should have a comment describing its purpose:

```bash
# Function to do something
function do_something {
  # ...
}
```

### Variable Naming

Use descriptive variable names:

- Constants should be in UPPER_CASE
- Variables should be in UPPER_CASE or snake_case
- Function names should be in snake_case

### Code Style

- Use 2-space indentation
- Use `[[ ]]` for conditional expressions when possible
- Use `$()` for command substitution instead of backticks
- Use `${variable}` instead of `$variable`
- Use double quotes around variables to prevent word splitting

## Troubleshooting Development Issues

### Common Issues

#### Script Not Executable

If you see an error like:

```
bash: ./roocode-modular.sh: Permission denied
```

Make the script executable:

```bash
chmod +x roocode-modular.sh
```

#### Syntax Errors

If you see an error like:

```
./roocode-modular.sh: line 42: syntax error near unexpected token `('
```

Check the syntax of the script, especially around line 42.

#### Test Failures

If a test fails, check the error message to identify the issue. The tests are designed to provide detailed error messages that help identify the problem.

## Contributing

When contributing to the RooCode Modular System, follow these guidelines:

1. **Create a branch**: Create a new branch for your changes
2. **Make changes**: Implement your changes following the guidelines in this document
3. **Run tests**: Run the appropriate tests to ensure that your changes don't break existing functionality
4. **Update documentation**: Update the user guide and developer guide
5. **Submit a pull request**: Submit a pull request with your changes

## System Requirements

The RooCode Modular System requires:

- Bash 4.0 or later
- Git
- Python 3.6 or later (for running Python tests)

## Future Development

Planned future enhancements include:

- Support for different experiment types (not just Python)
- Integration with CI/CD pipelines
- Web interface for managing experiments
- Enhanced reporting and visualization of results

## Conclusion

This guide provides an overview of the RooCode Modular System architecture, components, and guidelines for development. By following these guidelines, you can extend and modify the system while maintaining its quality and reliability.