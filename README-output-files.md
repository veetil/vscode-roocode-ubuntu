# Output Files Feature for RooCode Modular Workflow

This document describes the output files feature added to the RooCode modular workflow script.

## Overview

The output files feature allows you to specify files and folders from the experiment directory that should be copied to a dedicated output folder. This is useful for preserving important outputs from your experiments, such as:

- Generated code files
- Test results
- Documentation
- Logs
- Any other important artifacts

## Folder Structure

The output files are copied to a folder structure organized by session and branch:

```
/home/ubuntu/LaunchRoo/output/
└── session_<session_id>/
    └── branch_<branchname>/
        ├── file1.txt
        ├── file2.py
        └── subfolder/
            └── file3.md
```

This structure allows you to:
- Group all outputs from a single session together
- Separate outputs from different branches within the same session
- Maintain the relative paths of files and folders

## Usage

To use the output files feature, add the `--output` and `--session` parameters to your `roocode-modular.sh` command:

```bash
./roocode-modular.sh \
    --question "Your question" \
    --expt "experiment_name" \
    --output "file1.txt,folder1,subfolder/file2.py" \
    --session "unique_session_id"
```

### Parameters

- `--output`: A comma-separated list of files and/or folders to copy from the experiment directory to the output folder. Paths should be relative to the experiment directory. Use `*` to copy the entire experiment folder contents recursively.
- `--session`: A unique identifier for the session. This will be used to create the session folder.

### Special Case: Copying All Files

To copy the entire experiment folder contents recursively, use the special value `*` for the `--output` parameter:

```bash
./roocode-modular.sh \
    --question "Your question" \
    --expt "experiment_name" \
    --output "*" \
    --session "unique_session_id"
```

This will copy all files and directories from the experiment folder to the output folder, maintaining the same structure.

## Implementation Details

The output files feature is implemented in the `copy_output_files` function in `roocode-modular.sh`. This function:

1. Skips if no output files or session ID are provided
2. Gets the branch name from the git repository or from a temporary file
3. Sanitizes the session ID and branch name to create valid folder names
4. Creates the output folder structure
5. Copies each specified file or folder to the output folder, maintaining the relative paths

## Testing

The feature has been tested with two test scripts:

1. `test-output-files.sh` - Tests the basic functionality of copying specific files and folders
   - Verifies files are correctly copied to the output folder
   - Checks that the folder structure is created correctly
   - Ensures the content of the copied files is preserved

2. `test-output-all-files.sh` - Tests the `--output "*"` functionality
   - Verifies that all files and directories from the experiment folder are copied
   - Checks that the directory structure is maintained
   - Ensures the content of all files is preserved

## Limitations

- The feature requires both `--output` and `--session` parameters to work
- Files and folders must exist in the experiment directory
- The branch name is determined from the git repository, so the script must be run in a git repository