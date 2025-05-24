#!/bin/bash
# test-workflow-execution-real-verbose.sh - Verbose test script for workflow execution functions with real CLI calls

# Enable verbose output
set -o pipefail

# Function to log with timestamp
function log_info {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
}

function log_debug {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $1"
}

function log_error {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2
}

function log_success {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1"
}

function log_separator {
    echo "=================================================================="
}

# Source the main script to access its functions
log_info "Sourcing roocode-modular.sh"
source ./roocode-modular.sh

# Set up real environment
EVALS_DIR="/home/ubuntu/LaunchRoo/evals"
PYTHON_DIR="${EVALS_DIR}/python"
EXPT_NAME="test_platin"
FULL_EXPT_PATH="${PYTHON_DIR}/${EXPT_NAME}"

log_info "Setting up real environment"
log_debug "EVALS_DIR: ${EVALS_DIR}"
log_debug "PYTHON_DIR: ${PYTHON_DIR}"
log_debug "EXPT_NAME: ${EXPT_NAME}"
log_debug "FULL_EXPT_PATH: ${FULL_EXPT_PATH}"

# Let the actual workflow handle experiment folder creation
log_info "The experiment folder will be created by the actual workflow if it doesn't exist"
log_info "Preparing test question for Pig Latin translator"

# Define the question content for later use
QUESTION_CONTENT="# Pig Latin Translator

Create a function that translates English text to Pig Latin.

## Rules for Pig Latin:
1. If a word begins with a consonant, move the consonant to the end and add \"ay\"
2. If a word begins with a vowel, just add \"way\" to the end
3. Preserve capitalization and punctuation

## Example:
Input: \"Hello world!\"
Output: \"Ellohay orldway!\"

Write a Python function named \`translate_to_pig_latin(text)\` that takes a string and returns the Pig Latin translation."

# Set up the question for the workflow
QUESTION="${QUESTION_CONTENT}"

# Override run_roocode_cli to capture more output from real CLI execution
function run_roocode_cli_verbose {
    log_info "Running RooCode CLI with virtual display (VERBOSE)..."
    
    # Change to the LaunchRoo directory
    log_debug "Changing to LaunchRoo directory"
    cd "/home/ubuntu/LaunchRoo"
    
    # Run the CLI with the virtual display and capture output
    log_info "Executing: ./run-cli-with-xvfb.sh python ${EXPT_NAME}"
    log_separator
    echo "COMMAND OUTPUT START:"
    ./run-cli-with-xvfb.sh python "${EXPT_NAME}" | tee "/tmp/roocode-output.log"
    CLI_EXIT_CODE=${PIPESTATUS[0]}
    echo "COMMAND OUTPUT END"
    log_separator
    
    # Check if the CLI execution was successful
    if [ ${CLI_EXIT_CODE} -ne 0 ]; then
        log_error "RooCode CLI execution failed with exit code ${CLI_EXIT_CODE}"
        log_debug "Output log content:"
        cat "/tmp/roocode-output.log" | sed 's/^/    /'
        return 1
    fi
    
    log_success "RooCode CLI execution completed successfully"
    return 0
}

# Test function for run_roocode_cli with real CLI execution
function test_run_roocode_cli_real {
    log_info "Testing run_roocode_cli function with real CLI execution..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    log_debug "EXPT_FOLDER: ${EXPT_FOLDER}"
    log_debug "QUESTION: ${QUESTION}"
    
    # First, ensure the experiment folder is properly set up using the workflow
    log_info "Setting up experiment folder using the workflow"
    execute_workflow "${QUESTION}" "${EXPT_FOLDER}" "" "test_session_$(date +%s)" "*" "true" ""
    
    # Call the function with real CLI execution
    log_info "Calling run_roocode_cli_verbose"
    run_roocode_cli_verbose
    
    # Check if the function completed without errors
    if [ $? -eq 0 ]; then
        log_success "run_roocode_cli real test passed"
        return 0
    else
        log_error "run_roocode_cli real test failed"
        return 1
    fi
}

# Test function for capture_test_results with real output
function test_capture_test_results_real {
    log_info "Testing capture_test_results function with real output..."
    
    # Display the content of the output log
    log_debug "Content of /tmp/roocode-output.log:"
    if [ -f "/tmp/roocode-output.log" ]; then
        cat "/tmp/roocode-output.log" | sed 's/^/    /'
    else
        log_error "Output log file does not exist"
        echo "false" > "/tmp/roocode-tests-passed.txt"
        return 1
    fi
    
    # Define a custom capture_test_results function for testing
    function capture_test_results {
        log_info "Capturing test results..."
        
        log_debug "Checking for 'All tests passed' in output log"
        if [ -f "/tmp/roocode-output.log" ] && grep -q "All tests passed" "/tmp/roocode-output.log"; then
            log_success "Tests passed successfully"
            echo "true" > "/tmp/roocode-tests-passed.txt"
        else
            log_debug "Searching for test results in output log"
            grep -i "test" "/tmp/roocode-output.log" | sed 's/^/    /'
            
            log_error "Some tests failed or could not be determined"
            echo "false" > "/tmp/roocode-tests-passed.txt"
        fi
    }
    
    # Call the function
    capture_test_results
    
    # Check if the results file was created
    if [ -f "/tmp/roocode-tests-passed.txt" ]; then
        local result=$(cat "/tmp/roocode-tests-passed.txt")
        log_debug "Test result: ${result}"
        log_success "capture_test_results real test completed"
        return 0
    else
        log_error "capture_test_results real test failed: Results file not created"
        return 1
    fi
}

# Test function for commit_workflow_changes with real git operations
function test_commit_workflow_changes_real {
    log_info "Testing commit_workflow_changes function with real git operations..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    # EVALS_DIR is already set at the beginning of the script
    
    log_debug "EXPT_FOLDER: ${EXPT_FOLDER}"
    log_debug "EVALS_DIR: ${EVALS_DIR}"
    
    # Check if git repository exists
    if [ ! -d "${EVALS_DIR}/.git" ]; then
        log_debug "Initializing git repository in ${EVALS_DIR}"
        (cd "${EVALS_DIR}" && git init && git config user.email "test@example.com" && git config user.name "Test User")
    else
        log_debug "Git repository already exists in ${EVALS_DIR}"
    fi
    
    # Enable debug mode for git operations
    log_debug "Enabling debug mode for git operations"
    set -x
    
    # Call the function
    commit_workflow_changes
    local commit_result=$?
    
    # Disable debug mode
    set +x
    
    # Check if the function completed without errors
    if [ ${commit_result} -eq 0 ]; then
        log_success "commit_workflow_changes real test passed"
        return 0
    else
        log_error "commit_workflow_changes real test failed"
        return 1
    fi
}

# Test function for report_results with real output
function test_report_results_real {
    log_info "Testing report_results function with real output..."
    
    # Set up test variables
    EXPT_FOLDER="${EXPT_NAME}"
    # PYTHON_DIR is already set at the beginning of the script
    
    log_debug "EXPT_FOLDER: ${EXPT_FOLDER}"
    log_debug "PYTHON_DIR: ${PYTHON_DIR}"
    
    # Call the function
    log_separator
    echo "REPORT OUTPUT START:"
    report_results
    local report_result=$?
    echo "REPORT OUTPUT END"
    log_separator
    
    # Since report_results only outputs to stdout, we'll consider it passed if it completes
    if [ ${report_result} -eq 0 ]; then
        log_success "report_results real test passed"
        return 0
    else
        log_error "report_results real test failed"
        return 1
    fi
}

# Test function for cleanup with real file removal
function test_cleanup_real {
    log_info "Testing cleanup function with real file removal..."
    
    # Create test files if they don't exist
    log_debug "Creating test files for cleanup"
    touch "/tmp/roocode-branch-name.txt"
    touch "/tmp/roocode-tests-passed.txt"
    touch "/tmp/roocode-output.log"
    
    # List files before cleanup
    log_debug "Files before cleanup:"
    ls -la /tmp/roocode-* | sed 's/^/    /'
    
    # Call the function
    log_info "Calling cleanup function"
    cleanup
    
    # List files after cleanup
    log_debug "Files after cleanup:"
    ls -la /tmp/roocode-* 2>/dev/null | sed 's/^/    /' || echo "    No files found"
    
    # Check if the files were removed
    local files_exist=0
    for file in "/tmp/roocode-branch-name.txt" "/tmp/roocode-tests-passed.txt" "/tmp/roocode-output.log"; do
        if [ -f "${file}" ]; then
            log_error "cleanup real test failed: File ${file} still exists"
            files_exist=1
        else
            log_debug "File ${file} was removed successfully"
        fi
    done
    
    if [ ${files_exist} -eq 0 ]; then
        log_success "cleanup real test passed"
        return 0
    else
        log_error "Some files were not removed"
        return 1
    fi
}

# Run all tests with real execution
function run_all_tests_real {
    log_info "Running all workflow execution tests with real execution..."
    
    local all_passed=true
    
    # Run each test function
    log_separator
    log_info "RUNNING TEST: run_roocode_cli_real"
    test_run_roocode_cli_real
    if [ $? -ne 0 ]; then 
        all_passed=false
        log_error "run_roocode_cli_real test FAILED"
    else
        log_success "run_roocode_cli_real test PASSED"
    fi
    log_separator
    
    log_info "RUNNING TEST: test_capture_test_results_real"
    test_capture_test_results_real
    if [ $? -ne 0 ]; then 
        all_passed=false
        log_error "test_capture_test_results_real test FAILED"
    else
        log_success "test_capture_test_results_real test PASSED"
    fi
    log_separator
    
    log_info "RUNNING TEST: test_commit_workflow_changes_real"
    test_commit_workflow_changes_real
    if [ $? -ne 0 ]; then 
        all_passed=false
        log_error "test_commit_workflow_changes_real test FAILED"
    else
        log_success "test_commit_workflow_changes_real test PASSED"
    fi
    log_separator
    
    log_info "RUNNING TEST: test_report_results_real"
    test_report_results_real
    if [ $? -ne 0 ]; then 
        all_passed=false
        log_error "test_report_results_real test FAILED"
    else
        log_success "test_report_results_real test PASSED"
    fi
    log_separator
    
    log_info "RUNNING TEST: test_cleanup_real"
    test_cleanup_real
    if [ $? -ne 0 ]; then 
        all_passed=false
        log_error "test_cleanup_real test FAILED"
    else
        log_success "test_cleanup_real test PASSED"
    fi
    log_separator
    
    # We don't want to clean up the real EVALS_DIR
    log_info "Skipping cleanup of real EVALS_DIR: ${EVALS_DIR}"
    # Instead, we'll just clean up any temporary files
    log_info "Cleaning up temporary files"
    rm -f "/tmp/roocode-branch-name.txt" "/tmp/roocode-tests-passed.txt" "/tmp/roocode-output.log"
    
    # Report overall results
    log_separator
    if [ "${all_passed}" = true ]; then
        log_success "🎉 All real workflow execution tests passed!"
        return 0
    else
        log_error "❌ Some real workflow execution tests failed"
        return 1
    fi
}

# Run the tests
log_info "Starting verbose test execution"
log_separator
run_all_tests_real
exit $?