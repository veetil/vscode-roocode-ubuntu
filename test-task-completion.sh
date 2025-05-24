#!/bin/bash

# Test script for the task completion and test result capture functionality
# This script creates a mock output log with different patterns and tests the capture_test_results function

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
echo "Using temporary directory: ${TEST_DIR}"

# Copy the roocode-modular.sh script to the test directory
cp roocode-modular.sh "${TEST_DIR}/"
cd "${TEST_DIR}"

# Source the script to get access to its functions
source ./roocode-modular.sh

# Test case 1: Both taskCompleted and failed: 0 patterns are present (success case)
echo "Test case 1: Both patterns present (success case)"
echo "taskEvent -> taskCompleted" > /tmp/roocode-output.log
echo "failed: 0" >> /tmp/roocode-output.log

# Call the capture_test_results function
capture_test_results

# Check the results
echo "Task completed: $(cat /tmp/roocode-task-completed.txt)"
echo "Tests passed: $(cat /tmp/roocode-tests-passed.txt)"
echo ""

# Test case 2: Only taskCompleted pattern is present (task completed but tests failed)
echo "Test case 2: Only taskCompleted pattern present (task completed but tests failed)"
echo "taskEvent -> taskCompleted" > /tmp/roocode-output.log
echo "failed: 2" >> /tmp/roocode-output.log

# Call the capture_test_results function
capture_test_results

# Check the results
echo "Task completed: $(cat /tmp/roocode-task-completed.txt)"
echo "Tests passed: $(cat /tmp/roocode-tests-passed.txt)"
echo ""

# Test case 3: Neither pattern is present (task not completed and tests failed)
echo "Test case 3: Neither pattern present (task not completed and tests failed)"
echo "Some other output" > /tmp/roocode-output.log

# Call the capture_test_results function
capture_test_results

# Check the results
echo "Task completed: $(cat /tmp/roocode-task-completed.txt)"
echo "Tests passed: $(cat /tmp/roocode-tests-passed.txt)"
echo ""

# Clean up
cleanup
rm -rf "${TEST_DIR}"
echo "Test completed."