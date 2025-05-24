# RooCode Modular System User Guide

## Introduction

The RooCode Modular System is a command-line tool designed to streamline the workflow for creating and managing RooCode experiments. This guide will help you understand how to use the system effectively.

## Installation

The RooCode Modular System is pre-installed in the LaunchRoo environment. No additional installation steps are required.

## Basic Usage

The basic command structure is:

```bash
./roocode-modular.sh --question "Your question" --expt "experiment_name" [options]
```

### Required Parameters

- `--question`: The user question to save to question.md
- `--expt`: The experiment folder name

### Optional Parameters

- `--files`: A comma-separated list of source:destination file pairs
- `--prompt`: The prompt text to save to outline.md
- `--output`: A comma-separated list of files to copy to the output directory
- `--output-all`: Flag to copy all files to the output directory

## Examples

### Basic Example

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment"
```

This will:
1. Create a folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/`
2. Save the question to `question.md` in that folder
3. Set up git operations for the experiment

### Example with Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py"
```

This will:
1. Create a folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/`
2. Save the question to `question.md` in that folder
3. Copy `calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/calculator.py`
4. Copy `test_calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/test_calculator.py`
5. Set up git operations for the experiment

### Example with Prompt

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --prompt "Create a calculator with add, subtract, multiply, and divide functions."
```

This will:
1. Create a folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/`
2. Save the question to `question.md` in that folder
3. Save the prompt to `outline.md` in that folder
4. Set up git operations for the experiment

### Example with Output Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py" \
  --output "calculator.py,test_calculator.py"
```

This will:
1. Create a folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/`
2. Save the question to `question.md` in that folder
3. Copy `calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/calculator.py`
4. Copy `test_calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/test_calculator.py`
5. Set up git operations for the experiment
6. Copy `calculator.py` and `test_calculator.py` to the output directory

### Example with Output All Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py" \
  --output-all
```

This will:
1. Create a folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/`
2. Save the question to `question.md` in that folder
3. Copy `calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/calculator.py`
4. Copy `test_calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/test_calculator.py`
5. Set up git operations for the experiment
6. Copy all files in the experiment folder to the output directory

## File Structure

The RooCode Modular System creates the following file structure:

```
/home/ubuntu/LaunchRoo/evals/python/experiment_name/
├── question.md
├── outline.md (if prompt is provided)
└── [copied files]
```

Output files are stored in:

```
/home/ubuntu/LaunchRoo/output/session_test_session_timestamp_/branch_branch_name_/
├── question.md
├── outline.md (if prompt is provided)
└── [output files]
```

## Git Operations

The RooCode Modular System performs the following git operations:

1. Removes the remote for `/home/ubuntu/LaunchRoo/evals` if it exists
2. Checks out the main branch
3. Updates the local main branch with created files
4. Creates a new branch during workflow execution
5. Commits changes to the new branch

## Troubleshooting

### Common Issues

#### File Not Found

If you see an error like:

```
Error: Source file does not exist: file.py
```

Make sure the file exists at the specified path.

#### Invalid File Pair Format

If you see an error like:

```
Error: Invalid file pair format: file.py
Expected format: source:destination
```

Make sure you're using the correct format for file pairs: `source:destination`.

#### Experiment Folder Already Exists

If you see an error like:

```
Error: Experiment folder already exists: experiment_name
```

Choose a different experiment name or remove the existing folder.

## Getting Help

For more information, run:

```bash
./roocode-modular.sh --help
```

This will display the usage information and available options.

## Additional Resources

- [Developer Guide](DEVELOPER_GUIDE.md): Information for developers who want to extend or modify the system
- [Troubleshooting Guide](TROUBLESHOOTING.md): Detailed troubleshooting information
- [Examples](EXAMPLES.md): More examples of how to use the system