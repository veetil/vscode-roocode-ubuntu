#!/bin/bash
# test-workflow-execution.sh - Test script for workflow execution functions

# Source the main script to access its functions
source ./roocode-modular.sh

# Set up test environment
TEST_DIR="/tmp/roocode-test-workflow-execution"
EXPT_NAME="test_pig_latin"
FULL_TEST_PATH="${TEST_DIR}/${EXPT_NAME}"

# Create test directory
mkdir -p "${FULL_TEST_PATH}"

# Mock functions to avoid actual execution of external commands
function mock_run_cli {
    echo "Mocking run-cli-with-xvfb.sh execution..."
    echo "All tests passed" > "/tmp/roocode-output.log"
    return 0
}

function mock_git_commands {
    echo "Mocking git commands..."
    return 0
}

# Override functions that would execute external commands
cd() {
    echo "Mock cd to: $1"
    return 0
}

git() {
    echo "Mock git command: $@"
    if [[ "$1" == "branch" && "$2" == "--show-current" ]]; then
        echo "test-workflow-branch"
    fi
    return 0
}

# Mock grep function
grep() {
    if [[ "$1" == "-q" && "$2" == "All tests passed" && "$3" == "/tmp/roocode-output.log" ]]; then
        # For the specific test case, return success (0) to simulate finding the pattern
        return 0
    else
        echo "Mock grep: $@"
        return 1  # Simulate not finding the pattern
    fi
}

# Test function for run_roocode_cli
function test_run_roocode_cli {
    echo "Testing run_roocode_cli function..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    
    # Override the actual CLI execution
    eval "function ./run-cli-with-xvfb.sh { mock_run_cli; }"
    
    # Call the function
    run_roocode_cli
    
    # Check if the function completed without errors
    if [ $? -eq 0 ]; then
        echo "✅ run_roocode_cli test passed"
        return 0
    else
        echo "❌ run_roocode_cli test failed"
        return 1
    fi
}

# Test function for capture_test_results
function test_capture_test_results {
    echo "Testing capture_test_results function..."
    
    # Ensure the log file exists with test data
    echo "All tests passed" > "/tmp/roocode-output.log"
    
    # Call the function
    capture_test_results
    
    # Check if the results file was created
    if [ -f "/tmp/roocode-tests-passed.txt" ]; then
        local result=$(cat "/tmp/roocode-tests-passed.txt")
        if [ "${result}" == "true" ]; then
            echo "✅ capture_test_results test passed"
            return 0
        else
            echo "❌ capture_test_results test failed: Expected 'true', got '${result}'"
            return 1
        fi
    else
        echo "❌ capture_test_results test failed: Results file not created"
        return 1
    fi
}

# Test function for commit_workflow_changes
function test_commit_workflow_changes {
    echo "Testing commit_workflow_changes function..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    EVALS_DIR="${TEST_DIR}"
    
    # Override git diff to simulate changes to commit
    eval "function git { if [[ \"\$1\" == \"diff\" && \"\$2\" == \"--cached\" ]]; then return 1; else mock_git_commands; fi; }"
    
    # Call the function
    commit_workflow_changes
    
    # Check if the function completed without errors
    if [ $? -eq 0 ]; then
        echo "✅ commit_workflow_changes test passed"
        return 0
    else
        echo "❌ commit_workflow_changes test failed"
        return 1
    fi
}

# Test function for report_results
function test_report_results {
    echo "Testing report_results function..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    PYTHON_DIR="${TEST_DIR}"
    
    # Create test files
    echo "true" > "/tmp/roocode-tests-passed.txt"
    echo "test-workflow-branch" > "/tmp/roocode-branch-name.txt"
    
    # Call the function
    report_results
    
    # Since report_results only outputs to stdout, we'll consider it passed if it completes
    if [ $? -eq 0 ]; then
        echo "✅ report_results test passed"
        return 0
    else
        echo "❌ report_results test failed"
        return 1
    fi
}

# Test function for cleanup
function test_cleanup {
    echo "Testing cleanup function..."
    
    # Create test files
    touch "/tmp/roocode-branch-name.txt"
    touch "/tmp/roocode-tests-passed.txt"
    touch "/tmp/roocode-output.log"
    
    # Call the function
    cleanup
    
    # Check if the files were removed
    local files_exist=0
    for file in "/tmp/roocode-branch-name.txt" "/tmp/roocode-tests-passed.txt" "/tmp/roocode-output.log"; do
        if [ -f "${file}" ]; then
            echo "❌ cleanup test failed: File ${file} still exists"
            files_exist=1
        fi
    done
    
    if [ ${files_exist} -eq 0 ]; then
        echo "✅ cleanup test passed"
        return 0
    else
        return 1
    fi
}

# Run all tests
function run_all_tests {
    echo "Running all workflow execution tests..."
    
    local all_passed=true
    
    # Run each test function
    test_run_roocode_cli
    if [ $? -ne 0 ]; then all_passed=false; fi
    
    test_capture_test_results
    if [ $? -ne 0 ]; then all_passed=false; fi
    
    test_commit_workflow_changes
    if [ $? -ne 0 ]; then all_passed=false; fi
    
    test_report_results
    if [ $? -ne 0 ]; then all_passed=false; fi
    
    test_cleanup
    if [ $? -ne 0 ]; then all_passed=false; fi
    
    # Clean up test directory
    rm -rf "${TEST_DIR}"
    
    # Report overall results
    echo ""
    if [ "${all_passed}" = true ]; then
        echo "🎉 All workflow execution tests passed!"
        return 0
    else
        echo "❌ Some workflow execution tests failed"
        return 1
    fi
}

# Run the tests
run_all_tests
exit $?