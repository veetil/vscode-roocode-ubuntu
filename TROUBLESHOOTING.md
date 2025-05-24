# RooCode Modular System Troubleshooting Guide

This guide provides solutions to common issues you might encounter when using the RooCode Modular System.

## Common Issues

### Installation Issues

#### Script Not Executable

**Issue**: You see an error like:
```
bash: ./roocode-modular.sh: Permission denied
```

**Solution**: Make the script executable:
```bash
chmod +x roocode-modular.sh
```

#### Missing Dependencies

**Issue**: You see an error related to missing dependencies.

**Solution**: Ensure all required dependencies are installed:
```bash
# Install git if not already installed
sudo apt-get update
sudo apt-get install -y git

# Install Python if not already installed
sudo apt-get install -y python3 python3-pip
```

### Command-Line Arguments Issues

#### Missing Required Arguments

**Issue**: You see an error like:
```
Error: Missing required argument: --question
Error: Missing required argument: --expt
```

**Solution**: Provide all required arguments:
```bash
./roocode-modular.sh --question "Your question" --expt "experiment_name"
```

#### Invalid File Pair Format

**Issue**: You see an error like:
```
Error: Invalid file pair format: file.py
Expected format: source:destination
```

**Solution**: Use the correct format for file pairs:
```bash
./roocode-modular.sh --question "Your question" --expt "experiment_name" --files "source.py:destination.py"
```

### File Management Issues

#### Source File Not Found

**Issue**: You see an error like:
```
Error: Source file does not exist: file.py
```

**Solution**: Ensure the source file exists at the specified path:
```bash
# Check if the file exists
ls -la file.py

# If it doesn't exist, create it or specify the correct path
touch file.py
```

#### Experiment Folder Already Exists

**Issue**: You see an error like:
```
Error: Experiment folder already exists: experiment_name
```

**Solution**: Choose a different experiment name or remove the existing folder:
```bash
# Choose a different experiment name
./roocode-modular.sh --question "Your question" --expt "new_experiment_name"

# Or remove the existing folder
rm -rf /home/ubuntu/LaunchRoo/evals/python/experiment_name
./roocode-modular.sh --question "Your question" --expt "experiment_name"
```

### Git Issues

#### Git Not Initialized

**Issue**: You see an error related to git operations.

**Solution**: Ensure git is initialized in the evals directory:
```bash
cd /home/ubuntu/LaunchRoo/evals
git init
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

#### Git Remote Issues

**Issue**: You see an error related to git remote operations.

**Solution**: Check and fix git remote configuration:
```bash
cd /home/ubuntu/LaunchRoo/evals
git remote -v
git remote remove origin  # If needed
```

### Workflow Execution Issues

#### Workflow Execution Failed

**Issue**: The workflow execution fails with an error.

**Solution**: Check the error message for details. Common issues include:

1. **Missing files**: Ensure all required files are present
2. **Invalid file content**: Check the content of the files
3. **Git issues**: Check git configuration and operations

#### Branch Name Not Captured

**Issue**: The branch name is not captured during workflow execution.

**Solution**: Check the workflow execution process:
```bash
# Run with verbose output
./roocode-modular.sh --question "Your question" --expt "experiment_name" --verbose
```

### Output Issues

#### Output Files Not Copied

**Issue**: The output files are not copied to the output directory.

**Solution**: Check the output directory and ensure the files are specified correctly:
```bash
# Check the output directory
ls -la /home/ubuntu/LaunchRoo/output/session_test_session_*

# Specify the output files explicitly
./roocode-modular.sh --question "Your question" --expt "experiment_name" --output "file1.py,file2.py"

# Or use the output-all flag
./roocode-modular.sh --question "Your question" --expt "experiment_name" --output-all
```

#### Output Directory Not Created

**Issue**: The output directory is not created.

**Solution**: Check the workflow execution process and ensure the branch name is captured:
```bash
# Run with verbose output
./roocode-modular.sh --question "Your question" --expt "experiment_name" --verbose

# Check if the branch name file exists
cat /tmp/roocode-branch-name.txt
```

## Advanced Troubleshooting

### Debugging the Script

To debug the script, you can add the `-x` option to the shebang line:

```bash
#!/bin/bash -x
```

This will print each command and its arguments as they are executed.

### Checking Logs

Check the system logs for any relevant error messages:

```bash
journalctl -n 100
```

### Checking File Permissions

Ensure all files have the correct permissions:

```bash
# Check permissions of the script
ls -la roocode-modular.sh

# Ensure the script is executable
chmod +x roocode-modular.sh

# Check permissions of the experiment directory
ls -la /home/ubuntu/LaunchRoo/evals/python/

# Check permissions of the output directory
ls -la /home/ubuntu/LaunchRoo/output/
```

### Checking Disk Space

Ensure there is enough disk space:

```bash
df -h
```

### Checking Memory Usage

Ensure there is enough memory:

```bash
free -h
```

## Reporting Issues

If you encounter an issue that is not covered in this guide, please report it by creating an issue in the repository with the following information:

1. Description of the issue
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Error messages (if any)
6. System information (OS, bash version, git version, etc.)

## Getting Help

If you need further assistance, you can:

1. Check the [User Guide](USER_GUIDE.md) for usage information
2. Check the [Developer Guide](DEVELOPER_GUIDE.md) for development information
3. Contact the system administrator or maintainer