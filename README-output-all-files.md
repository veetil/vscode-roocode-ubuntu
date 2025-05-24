# RooCode Modular: Output All Files Feature

## Overview

The `--output "*"` feature allows you to copy the entire experiment folder to the output directory. This is useful when you want to preserve all files and directories created during an experiment, without having to specify each file individually.

## Usage

```bash
./roocode-modular.sh --question "Your question" --expt "experiment_name" --output "*" --session "session_id"
```

## How It Works

When you specify `--output "*"`, the script will:

1. Create the output directory structure: `/home/ubuntu/LaunchRoo/output/session_<session_id>/branch_<branch_name>/`
2. Copy all files and directories from the experiment folder to the output directory
3. Preserve the directory structure of the experiment folder

## Example

```bash
./roocode-modular.sh \
    --question "Test question for output all files" \
    --expt "test_experiment" \
    --files "source1.txt:dest1.txt,source2.txt:dest2.txt" \
    --output "*" \
    --session "test_session"
```

This will:
1. Create the experiment folder with the specified files
2. Copy all files and directories from the experiment folder to the output directory
3. The output directory will be: `/home/ubuntu/LaunchRoo/output/session_test_session/branch_<branch_name>/`

## Benefits

- **Simplicity**: No need to specify each file individually
- **Completeness**: Ensures all files are preserved, including those created during the experiment
- **Structure Preservation**: Maintains the directory structure of the experiment folder

## Testing

You can test this feature using the `test-output-all-files.sh` script:

```bash
./test-output-all-files.sh
```

This script will:
1. Set up a test environment with sample files
2. Run the `roocode-modular.sh` script with `--output "*"`
3. Verify that all files were copied correctly to the output directory
4. Clean up the test environment