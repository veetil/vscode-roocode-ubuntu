#!/bin/bash
# test-timeout.sh - Test the timeout parameter in workflow-verbose.sh

# Set a short timeout (10 seconds) to verify it works
./workflow-verbose.sh \
  --question "Test timeout functionality" \
  --expt "test_timeout_$(date +%s)" \
  --timeout 10 \
  --output "*" \
  --session "timeout_test"

# Check the exit code
if [ $? -eq 0 ]; then
  echo "Test completed successfully"
else
  echo "Test failed with exit code $?"
fi