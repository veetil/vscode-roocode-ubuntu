#!/bin/bash
# workflow-verbose.sh - Verbose script for executing RooCode workflow with real CLI calls

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

# Function to display usage information
function display_usage {
    echo "Usage: ./workflow-verbose.sh --question \"User question\" --expt \"experiment_folder\" [--prompt \"Optional prompt\"] [--output \"file1,folder1\"] [--session \"session_id\"] [--files \"source1:dest1,source2:dest2\"] [--timeout seconds]"
    echo ""
    echo "Options:"
    echo "  --question  The user question to save to question.md (required)"
    echo "  --expt      The experiment folder name (required)"
    echo "  --prompt    The prompt text to save to outline.md (optional)"
    echo "  --output    A comma-separated list of files/folders to copy to the output folder (optional)"
    echo "              Use '*' to copy all files from the experiment folder"
    echo "  --session   The session ID for the output folder name (optional)"
    echo "  --files     A comma-separated list of source:destination file pairs (optional)"
    echo "  --timeout   Timeout in seconds for the CLI execution (default: 300)"
    echo "  --help      Display this help message"
    echo ""
    exit 1
}

# Function to parse command-line arguments
function parse_arguments {
    # Default values
    QUESTION=""
    EXPT_FOLDER=""
    PROMPT=""
    OUTPUT_FILES=""
    SESSION_ID="session_$(date +%s)"
    FILES=""
    TIMEOUT=300  # Default timeout: 5 minutes (300 seconds)

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --question)
                QUESTION="$2"
                shift 2
                ;;
            --expt)
                EXPT_FOLDER="$2"
                shift 2
                ;;
            --prompt)
                PROMPT="$2"
                shift 2
                ;;
            --output)
                OUTPUT_FILES="$2"
                shift 2
                ;;
            --session)
                SESSION_ID="$2"
                shift 2
                ;;
            --files)
                FILES="$2"
                shift 2
                ;;
            --timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            --help)
                display_usage
                ;;
            *)
                log_error "Unknown option $1"
                display_usage
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$QUESTION" ]]; then
        log_error "--question is required"
        display_usage
    fi

    if [[ -z "$EXPT_FOLDER" ]]; then
        log_error "--expt is required"
        display_usage
    fi
}

# Source the main script to access its functions
log_info "Sourcing roocode-modular.sh"
source ./roocode-modular.sh

# Override run_roocode_cli to capture more output from real CLI execution
function run_roocode_cli_verbose {
    log_info "Running RooCode CLI with virtual display (VERBOSE)..."
    
    # Change to the LaunchRoo directory
    log_debug "Changing to LaunchRoo directory"
    cd "/home/ubuntu/LaunchRoo"
    
    # Run the CLI with the virtual display and capture output
    log_info "Executing: ./run-cli-with-xvfb.sh python ${EXPT_FOLDER} with timeout ${TIMEOUT}s"
    log_separator
    echo "COMMAND OUTPUT START:"
    
    # Convert timeout from seconds to milliseconds for the ROO_TASK_TIMEOUT environment variable
    export ROO_TASK_TIMEOUT=$((TIMEOUT * 1000))
    
    # Use timeout command as a fallback in case the environment variable isn't picked up
    timeout ${TIMEOUT}s ./run-cli-with-xvfb.sh python "${EXPT_FOLDER}" | tee "/tmp/roocode-output.log"
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

# Main workflow function
function run_workflow {
    log_info "Starting verbose workflow execution..."
    
    # Set up environment
    EVALS_DIR="/home/ubuntu/LaunchRoo/evals"
    PYTHON_DIR="${EVALS_DIR}/python"
    FULL_EXPT_PATH="${PYTHON_DIR}/${EXPT_FOLDER}"
    
    log_info "Setting up environment"
    log_debug "EVALS_DIR: ${EVALS_DIR}"
    log_debug "PYTHON_DIR: ${PYTHON_DIR}"
    log_debug "EXPT_NAME: ${EXPT_FOLDER}"
    log_debug "FULL_EXPT_PATH: ${FULL_EXPT_PATH}"
    
    # Execute the workflow
    log_info "Executing workflow"
    log_debug "QUESTION: ${QUESTION}"
    log_debug "PROMPT: ${PROMPT}"
    log_debug "SESSION_ID: ${SESSION_ID}"
    log_debug "OUTPUT_FILES: ${OUTPUT_FILES}"
    log_debug "FILES: ${FILES}"
    log_debug "TIMEOUT: ${TIMEOUT} seconds"
    
    # Determine if we should output all files
    OUTPUT_ALL="false"
    if [[ "${OUTPUT_FILES}" == "*" ]]; then
        OUTPUT_ALL="true"
        log_debug "OUTPUT_ALL: true (copying all files)"
    fi
    
    # Execute the workflow using the function from roocode-modular.sh
    log_info "Setting up experiment folder using the workflow"
    execute_workflow "${QUESTION}" "${EXPT_FOLDER}" "${PROMPT}" "${SESSION_ID}" "${OUTPUT_FILES}" "${OUTPUT_ALL}" "" "${TIMEOUT}"
    
    # Run the RooCode CLI with verbose output
    log_info "Running RooCode CLI with verbose output"
    run_roocode_cli_verbose
    if [ $? -ne 0 ]; then
        log_error "RooCode CLI execution failed"
        exit 1
    fi
    
    # Capture branch name for output folder
    log_info "Capturing branch name for output folder"
    capture_branch_name
    
    # Copy output files if specified
    log_info "Copying output files"
    copy_output_files
    
    # Capture test results
    log_info "Capturing test results"
    capture_test_results
    
    # Commit changes
    log_info "Committing workflow changes"
    commit_workflow_changes
    
    # Report results
    log_separator
    echo "WORKFLOW RESULTS:"
    report_results
    log_separator
    
    # Clean up
    log_info "Cleaning up"
    cleanup
    
    log_success "Workflow execution completed successfully"
}

# Main execution
log_info "Starting verbose workflow script"
parse_arguments "$@"
run_workflow
exit $?