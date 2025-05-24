# RooCode Workflow Timeout Feature

This document describes the timeout feature added to the RooCode workflow scripts.

## Overview

The timeout feature allows you to set a maximum execution time for the RooCode CLI process. This is useful for preventing long-running tasks from consuming excessive resources or for testing purposes.

## Usage

You can specify a timeout when running the workflow scripts using the `--timeout` parameter:

```bash
./workflow-verbose.sh --question "Your question" --expt "experiment_name" --timeout 300
```

The timeout value is specified in seconds. The default timeout is 300 seconds (5 minutes) if not specified.

## Implementation Details

The timeout is implemented in two ways:

1. Setting the `ROO_TASK_TIMEOUT` environment variable (in milliseconds) which is used by the RooCode CLI internally.
2. Using the Linux `timeout` command as a fallback mechanism to ensure the process is terminated after the specified duration.

## Files Modified

The following files were modified to implement this feature:

- `roocode-modular.sh`: Added timeout parameter handling and implementation
- `workflow-verbose.sh`: Added timeout parameter passing to the execute_workflow function

## Testing

You can test the timeout functionality using the provided test script:

```bash
./test-timeout.sh
```

This script sets a short timeout (10 seconds) to verify that the timeout mechanism works correctly.