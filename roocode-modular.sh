#!/bin/bash
# roocode-modular.sh - Enhanced RooCode CLI workflow

# Constants
EVALS_DIR="/home/ubuntu/LaunchRoo/evals"
PYTHON_DIR="${EVALS_DIR}/python"

# Variables to store command-line arguments
QUESTION=""
EXPT_FOLDER=""
FILES=""
PROMPT=""
OUTPUT_FILES=""
SESSION_ID=""
TIMEOUT=300  # Default timeout: 5 minutes (300 seconds)
# Function to display usage information
function display_usage {
  echo "Usage: ./roocode-modular.sh --question \"User question\" --expt \"experiment_folder\" [--files \"source1:dest1,source2:dest2\"] [--prompt \"Optional prompt\"] [--output \"file1,folder1\"] [--session \"session_id\"] [--timeout seconds]"
  echo ""
  echo "Options:"
  echo "  --question  The user question to save to question.md (required)"
  echo "  --expt      The experiment folder name (required)"
  echo "  --files     A comma-separated list of source:destination file pairs (optional)"
  echo "  --prompt    The prompt text to save to outline.md (optional)"
  echo "  --output    A comma-separated list of files/folders to copy to the output folder (optional)"
  echo "  --session   The session ID for the output folder name (optional)"
  echo "  --timeout   Timeout in seconds for the CLI execution (default: 300)"
  echo ""
  exit 1
}
# Function to parse command-line arguments
function parse_arguments {
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
      --files)
        FILES="$2"
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
      --timeout)
        TIMEOUT="$2"
        shift 2
        ;;
      --help)
        display_usage
        ;;
      *)
        echo "Error: Unknown option $1"
        display_usage
        ;;
    esac
  done
}

# Function to validate inputs
function validate_inputs {
  # Validate question (required)
  if [[ -z "$QUESTION" ]]; then
    echo "Error: --question is required"
    display_usage
  fi

  # Validate experiment folder (required)
  if [[ -z "$EXPT_FOLDER" ]]; then
    echo "Error: --expt is required"
    display_usage
  fi

  # Validate files format (optional)
  if [[ -n "$FILES" ]]; then
    IFS=',' read -ra FILE_PAIRS <<< "$FILES"
    for pair in "${FILE_PAIRS[@]}"; do
      source=$(echo "$pair" | cut -d':' -f1)
      if [[ ! -f "$source" ]]; then
        echo "Error: Source file '$source' does not exist"
        exit 1
      fi
      
      # Check if the format is valid (contains a colon)
      if [[ "$pair" != *:* ]]; then
        echo "Error: Invalid file pair format '$pair'. Expected format: source:destination"
        exit 1
      fi
    done
  fi

  # No specific validation for prompt
  echo "Input validation successful."
}

# Function to create or verify experiment folder
function manage_experiment_folder {
  FULL_EXPT_PATH="${PYTHON_DIR}/${EXPT_FOLDER}"
  
  # Check if the experiment folder exists
  if [[ -d "$FULL_EXPT_PATH" ]]; then
    echo "Experiment folder '$EXPT_FOLDER' already exists."
    
    # Verify it's a valid experiment folder (has Python files)
    if [[ $(find "$FULL_EXPT_PATH" -name "*.py" | wc -l) -eq 0 ]]; then
      echo "Warning: Experiment folder does not contain any Python files."
    fi
  else
    echo "Creating experiment folder '$EXPT_FOLDER'..."
    mkdir -p "$FULL_EXPT_PATH"
    mkdir -p "$FULL_EXPT_PATH/docs"
    
    # Create a basic structure with placeholder files
    touch "$FULL_EXPT_PATH/${EXPT_FOLDER}_test.py"
    touch "$FULL_EXPT_PATH/${EXPT_FOLDER}.py"
    
    echo "Experiment folder created successfully."
  fi
  
  # Set the current experiment folder path as a global variable
  CURRENT_EXPT_PATH="$FULL_EXPT_PATH"
  echo "Experiment folder path: $CURRENT_EXPT_PATH"
}

# Function to save user question to question.md
function save_question {
  local question_file="${CURRENT_EXPT_PATH}/question.md"
  
  echo "Saving user question to ${question_file}..."
  
  # Create the file and write the question
  echo "${QUESTION}" > "${question_file}"
  
  # Check if the file was created successfully
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to save question to ${question_file}"
    exit 1
  fi
  
  echo "Question saved successfully."
}

# Function to save prompt to outline.md if provided
function save_prompt {
  # Skip if no prompt was provided
  if [[ -z "${PROMPT}" ]]; then
    echo "No prompt provided, skipping outline.md creation."
    return 0
  fi
  
  local outline_file="${CURRENT_EXPT_PATH}/outline.md"
  
  echo "Saving prompt to ${outline_file}..."
  
  # Create the file and write the prompt
  echo "${PROMPT}" > "${outline_file}"
  
  # Check if the file was created successfully
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to save prompt to ${outline_file}"
    exit 1
  fi
  
  echo "Prompt saved successfully."
}

# Function to copy specified files
function copy_files {
  # Skip if no files were specified
  if [[ -z "${FILES}" ]]; then
    echo "No files specified, skipping file copying."
    return 0
  fi
  
  echo "Copying specified files to ${CURRENT_EXPT_PATH}..."
  
  # Split the comma-separated list of file pairs
  IFS=',' read -ra FILE_PAIRS <<< "${FILES}"
  
  for pair in "${FILE_PAIRS[@]}"; do
    # Split the source:destination pair
    IFS=':' read -ra PARTS <<< "${pair}"
    
    if [[ ${#PARTS[@]} -ne 2 ]]; then
      echo "Error: Invalid file pair format: ${pair}"
      echo "Expected format: source:destination"
      exit 1
    fi
    
    local source="${PARTS[0]}"
    local destination="${PARTS[1]}"
    
    # Verify the source file exists
    if [[ ! -f "${source}" ]]; then
      echo "Error: Source file does not exist: ${source}"
      exit 1
    fi
    
    # Create the destination directory if needed
    local dest_path="${CURRENT_EXPT_PATH}/${destination}"
    local dest_dir=$(dirname "${dest_path}")
    mkdir -p "${dest_dir}"
    
    # Copy the file
    cp "${source}" "${dest_path}"
    
    # Check if the copy was successful
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to copy ${source} to ${dest_path}"
      exit 1
    fi
    
    echo "Copied ${source} to ${dest_path}"
  done
  
  echo "All files copied successfully."
}

# Function to remove remote if it exists
function remove_remote {
  echo "Checking for remote in evals repository..."
  
  # Change to the evals directory
  cd "${EVALS_DIR}"
  
  # Check if a remote exists
  if git remote -v | grep -q "github.com/cte/eval"; then
    echo "Remote found, removing..."
    git remote remove origin
    
    # Check if the remote was removed successfully
    if [ $? -ne 0 ]; then
      echo "Error: Failed to remove remote"
      exit 1
    fi
    
    echo "Remote removed successfully."
  else
    echo "No remote found, skipping removal."
  fi
}

# Function to checkout main branch
function checkout_main {
  echo "Checking out main branch..."
  
  # Change to the evals directory
  cd "${EVALS_DIR}"
  
  # Checkout the main branch
  git checkout main
  
  # Check if the checkout was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to checkout main branch"
    exit 1
  fi
  
  echo "Main branch checked out successfully."
}

# Function to update main branch with created files
function update_main {
  echo "Updating main branch with created files..."
  
  # Change to the evals directory
  cd "${EVALS_DIR}"
  
  # Add all changes
  git add .
  
  # Check if there are any changes to commit
  if git diff --cached --quiet; then
    echo "No changes to commit, skipping update."
    return 0
  fi
  
  # Commit the changes
  git commit -m "Add files for experiment: ${EXPT_FOLDER}"
  
  # Check if the commit was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to commit changes to main branch"
    exit 1
  fi
  
  echo "Main branch updated successfully."
}

# Function to capture the CLI-created branch name
function capture_branch_name {
  echo "Capturing CLI-created branch name..."
  
  # Change to the evals directory
  cd "${EVALS_DIR}"
  
  # Get the current branch name
  BRANCH_NAME=$(git branch --show-current)
  
  # Check if we got a branch name
  if [ -z "${BRANCH_NAME}" ]; then
    echo "Warning: Failed to capture branch name, using fallback"
    BRANCH_NAME="unknown-branch"
  fi
  
  # Store the branch name for later reporting
  echo "${BRANCH_NAME}" > "/tmp/roocode-branch-name.txt"
  
  echo "Captured branch name: ${BRANCH_NAME}"
}

# Note: No need for commit_workflow_changes function as the RooCode CLI
# automatically handles git commits after task completion

# Function to perform all git operations
function manage_git {
  remove_remote
  checkout_main
  update_main
  # capture_branch_name will be called after workflow execution
}

# Function to sanitize folder name (remove invalid characters)
function sanitize_folder_name {
  local name="$1"
  
  # Replace invalid characters (/, spaces, newlines, etc.) with underscores
  echo "$name" | tr -c '[:alnum:]_-' '_'
}

# Function to copy output files/folders to the output folder
function copy_output_files {
  # Skip if no output files were specified
  if [[ -z "${OUTPUT_FILES}" ]]; then
    echo "No output files specified, skipping output folder creation."
    return 0
  fi
  
  # Skip if no session ID was provided
  if [[ -z "${SESSION_ID}" ]]; then
    echo "No session ID provided, skipping output folder creation."
    return 0
  fi
  
  echo "Copying output files to output folder..."
  
  # Get the branch name
  local branch_name=""
  if [[ -f "/tmp/roocode-branch-name.txt" ]]; then
    branch_name=$(cat "/tmp/roocode-branch-name.txt")
  else
    echo "Warning: Branch name not found, using 'unknown-branch'"
    branch_name="unknown-branch"
  fi
  
  # Sanitize session ID and branch name
  local sanitized_session=$(sanitize_folder_name "${SESSION_ID}")
  local sanitized_branch=$(sanitize_folder_name "${branch_name}")
  
  # Create the output folder structure with session and branch folders
  local session_folder="session_${sanitized_session}"
  local branch_folder="branch_${sanitized_branch}"
  local output_path="/home/ubuntu/LaunchRoo/output/${session_folder}/${branch_folder}"
  
  echo "Creating output folder: ${output_path}"
  mkdir -p "${output_path}"
  
  # Split the comma-separated list of output files/folders
  IFS=',' read -ra OUTPUT_ITEMS <<< "${OUTPUT_FILES}"
  
  # Check if "*" is specified to copy the entire experiment folder
  if [[ "${OUTPUT_FILES}" == "*" ]]; then
    echo "Copying entire experiment folder contents recursively..."
    
    # Copy all files and directories from the experiment folder
    for item in "${CURRENT_EXPT_PATH}"/*; do
      if [[ -e "${item}" ]]; then
        local item_name=$(basename "${item}")
        local dest_path="${output_path}/${item_name}"
        
        # Copy the item (file or directory)
        if [[ -d "${item}" ]]; then
          # It's a directory, use cp -r
          cp -r "${item}" "${output_path}/"
        else
          # It's a file
          cp "${item}" "${output_path}/"
        fi
        
        echo "Copied ${item} to ${output_path}/"
      fi
    done
  else
    # Process individual output items
    for item in "${OUTPUT_ITEMS[@]}"; do
      local source_path="${CURRENT_EXPT_PATH}/${item}"
      local dest_path="${output_path}/${item}"
      
      # Check if the source exists
      if [[ ! -e "${source_path}" ]]; then
        echo "Warning: Source item does not exist: ${source_path}"
        continue
      fi
      
      # Create the destination directory if needed
      local dest_dir=$(dirname "${dest_path}")
      mkdir -p "${dest_dir}"
      
      # Copy the item (file or directory)
      if [[ -d "${source_path}" ]]; then
        # It's a directory, use cp -r
        cp -r "${source_path}" "${dest_path}"
      else
        # It's a file
        cp "${source_path}" "${dest_path}"
      fi
    
      # Check if the copy was successful
      if [[ $? -ne 0 ]]; then
        echo "Error: Failed to copy ${source_path} to ${dest_path}"
        exit 1
      fi
      
      echo "Copied ${source_path} to ${dest_path}"
    done
  fi
  
  echo "All output files copied successfully to ${output_path}"
}

# Function to execute the workflow with direct parameters
function execute_workflow {
  local question="$1"
  local expt="$2"
  local prompt="$3"
  local session="$4"
  local output_files="$5"
  local output_all="$6"
  local expt_dir="$7"
  local timeout="$8"
  
  # Set global variables
  QUESTION="$question"
  EXPT_FOLDER="$expt"
  PROMPT="$prompt"
  SESSION_ID="$session"
  
  # Set timeout if provided
  if [[ -n "$timeout" ]]; then
    TIMEOUT="$timeout"
  fi
  
  # Handle output_all flag
  if [[ "$output_all" == "true" ]]; then
    OUTPUT_FILES="*"
  else
    OUTPUT_FILES="$output_files"
  fi
  
  # If experiment directory is provided, override the default
  if [[ -n "$expt_dir" ]]; then
    CURRENT_EXPT_PATH="$expt_dir"
  else
    # Otherwise, use the standard path
    manage_experiment_folder
  fi
  
  # Execute workflow steps
  save_question
  save_prompt
  
  # Skip file copying in test mode
  if [[ "$expt_dir" != "/tmp/"* ]]; then
    copy_files
    manage_git
  fi
  
  return 0
}
# Function to run the RooCode CLI with virtual display
function run_roocode_cli {
  echo "Running RooCode CLI with virtual display..."
  
  # Change to the LaunchRoo directory
  cd "/home/ubuntu/LaunchRoo"
  
  # Set the ROO_TASK_TIMEOUT environment variable (in milliseconds)
  export ROO_TASK_TIMEOUT=$((TIMEOUT * 1000))
  echo "Using timeout: ${TIMEOUT} seconds (${ROO_TASK_TIMEOUT} ms)"
  
  # Run the CLI with the virtual display and timeout
  timeout ${TIMEOUT}s ./run-cli-with-xvfb.sh python "${EXPT_FOLDER}" > "/tmp/roocode-output.log" 2>&1
  
  # Check if the CLI execution was successful
  CLI_EXIT_CODE=$?
  if [ ${CLI_EXIT_CODE} -ne 0 ]; then
    echo "Error: RooCode CLI execution failed with exit code ${CLI_EXIT_CODE}"
    echo "See /tmp/roocode-output.log for details"
    exit 1
  fi
  
  echo "RooCode CLI execution completed."
}

# Function to capture test results
function capture_test_results {
  echo "Capturing test results..."
  
  # Check 1: Look for taskCompleted pattern to determine if the task completed
  if grep -q "taskEvent -> taskCompleted" "/tmp/roocode-output.log"; then
    TASK_COMPLETED=true
    echo "Task completed successfully."
    
    # Check 2: Look for failed: 0 pattern to determine if tests passed
    if grep -q "failed: 0" "/tmp/roocode-output.log"; then
      TESTS_PASSED=true
      echo "All tests passed (failed: 0)."
    else
      TESTS_PASSED=false
      echo "Some tests failed (failed count > 0)."
    fi
  else
    TASK_COMPLETED=false
    TESTS_PASSED=false
    echo "Task did not complete successfully."
  fi
  
  # Store the test results for later reporting
  if [ "${TESTS_PASSED}" = true ]; then
    echo "true" > "/tmp/roocode-tests-passed.txt"
  else
    echo "false" > "/tmp/roocode-tests-passed.txt"
  fi
  
  # Store the task completion status
  if [ "${TASK_COMPLETED}" = true ]; then
    echo "true" > "/tmp/roocode-task-completed.txt"
  else
    echo "false" > "/tmp/roocode-task-completed.txt"
  fi
}

# Function to commit workflow changes
function commit_workflow_changes {
  echo "Committing workflow changes..."
  
  # Change to the evals directory
  cd "${EVALS_DIR}"
  
  # Add all changes
  git add .
  
  # Check if there are any changes to commit
  if git diff --cached --quiet; then
    echo "No changes to commit, skipping commit."
    return 0
  fi
  
  # Commit the changes
  git commit -m "Workflow execution results for experiment: ${EXPT_FOLDER}"
  
  # Check if the commit was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to commit changes to workflow branch"
    exit 1
  fi
  
  echo "Changes committed successfully to workflow branch."
}

# Function to report results
function report_results {
  echo ""
  echo "========================================"
  echo "RooCode Modular Workflow Results"
  echo "========================================"
  echo ""
  
  # Report task completion status
  if [ -f "/tmp/roocode-task-completed.txt" ]; then
    TASK_COMPLETED=$(cat "/tmp/roocode-task-completed.txt")
    if [ "${TASK_COMPLETED}" = "true" ]; then
      echo "Task Completion: COMPLETED"
    else
      echo "Task Completion: INCOMPLETE"
    fi
  else
    echo "Task Completion: UNKNOWN"
  fi
  
  # Report test results
  if [ -f "/tmp/roocode-tests-passed.txt" ]; then
    TESTS_PASSED=$(cat "/tmp/roocode-tests-passed.txt")
    if [ "${TESTS_PASSED}" = "true" ]; then
      echo "Tests: PASSED"
    else
      echo "Tests: FAILED"
    fi
  else
    echo "Tests: UNKNOWN"
  fi
  
  # Report branch name
  if [ -f "/tmp/roocode-branch-name.txt" ]; then
    BRANCH_NAME=$(cat "/tmp/roocode-branch-name.txt")
    echo "Branch: ${BRANCH_NAME}"
  else
    echo "Branch: UNKNOWN"
  fi
  
  echo ""
  echo "Experiment: ${EXPT_FOLDER}"
  echo "Question file: ${PYTHON_DIR}/${EXPT_FOLDER}/question.md"
  if [ -n "${PROMPT}" ]; then
    echo "Outline file: ${PYTHON_DIR}/${EXPT_FOLDER}/outline.md"
  fi
  
  echo ""
  echo "========================================"
}

# Function to clean up temporary files
function cleanup {
  echo "Cleaning up temporary files..."
  
  rm -f "/tmp/roocode-branch-name.txt"
  rm -f "/tmp/roocode-tests-passed.txt"
  rm -f "/tmp/roocode-task-completed.txt"
  rm -f "/tmp/roocode-output.log"
  
  echo "Cleanup completed."
}

# Main function
function main {
  echo "Starting RooCode modular workflow..."
  
  parse_arguments "$@"
  validate_inputs
  manage_experiment_folder
  save_question
  save_prompt
  copy_files
  manage_git
  
  # Execute RooCode CLI with virtual display
  run_roocode_cli
  capture_test_results
  commit_workflow_changes
  
  # Capture branch name for output folder
  capture_branch_name
  
  # Copy output files if specified
  copy_output_files
  
  # Report results and clean up
  report_results
  cleanup
  
  echo "RooCode modular workflow completed successfully."
}

# Execute main function only when script is run directly, not when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi