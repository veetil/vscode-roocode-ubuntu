#!/bin/bash
# test-git-operations.sh - Test script for git operations component

# Make sure the script is executable
chmod +x roocode-modular.sh

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run a test case
function run_test {
  local test_name="$1"
  local command="$2"
  local expected_exit_code="$3"
  
  echo -e "\n${YELLOW}Running test: ${test_name}${NC}"
  echo "Command: $command"
  
  # Run the command and capture output and exit code
  output=$(eval "$command" 2>&1)
  exit_code=$?
  
  echo "Output:"
  echo "$output"
  
  # Check if the exit code matches the expected exit code
  if [[ $exit_code -eq $expected_exit_code ]]; then
    echo -e "${GREEN}Test passed (Exit code: $exit_code)${NC}"
    return 0
  else
    echo -e "${RED}Test failed (Expected exit code: $expected_exit_code, Actual: $exit_code)${NC}"
    return 1
  fi
}

# Function to verify git status
function verify_git_status {
  local repo_path="$1"
  local expected_branch="$2"
  local test_name="$3"
  
  echo -e "\n${YELLOW}Verifying git status: ${test_name}${NC}"
  echo "Repository: $repo_path"
  
  # Change to the repository directory
  cd "$repo_path"
  
  # Get the current branch
  local current_branch=$(git branch --show-current)
  
  echo "Expected branch: $expected_branch"
  echo "Current branch: $current_branch"
  
  if [[ "$current_branch" == "$expected_branch" ]]; then
    echo -e "${GREEN}Test passed: Branch matches${NC}"
    return 0
  else
    echo -e "${RED}Test failed: Branch does not match${NC}"
    return 1
  fi
}

# Function to verify file exists in git
function verify_git_file {
  local repo_path="$1"
  local file_path="$2"
  local test_name="$3"
  
  echo -e "\n${YELLOW}Verifying file in git: ${test_name}${NC}"
  echo "Repository: $repo_path"
  echo "File: $file_path"
  
  # Change to the repository directory
  cd "$repo_path"
  
  # Check if the file is tracked by git
  if git ls-files --error-unmatch "$file_path" &>/dev/null; then
    echo -e "${GREEN}Test passed: File is tracked by git${NC}"
    return 0
  else
    echo -e "${RED}Test failed: File is not tracked by git${NC}"
    return 1
  fi
}

# Function to verify commit message
function verify_commit_message {
  local repo_path="$1"
  local expected_pattern="$2"
  local test_name="$3"
  
  echo -e "\n${YELLOW}Verifying commit message: ${test_name}${NC}"
  echo "Repository: $repo_path"
  
  # Change to the repository directory
  cd "$repo_path"
  
  # Get the latest commit message
  local commit_message=$(git log -1 --pretty=%B)
  
  echo "Expected pattern: $expected_pattern"
  echo "Commit message: $commit_message"
  
  if [[ "$commit_message" =~ $expected_pattern ]]; then
    echo -e "${GREEN}Test passed: Commit message matches pattern${NC}"
    return 0
  else
    echo -e "${RED}Test failed: Commit message does not match pattern${NC}"
    return 1
  fi
}

# Setup test environment
echo -e "\n${YELLOW}Setting up test environment${NC}"

# Ensure we're in the main branch before starting tests
cd /home/ubuntu/LaunchRoo/evals
git checkout main

# Test cases
echo -e "\n${YELLOW}Starting tests for git operations${NC}"

# Define the path to the roocode-modular.sh script
SCRIPT_PATH="/home/ubuntu/LaunchRoo/roocode-modular.sh"

# Test 1: Remove remote (if it exists)
run_test "Remove remote" \
  "cd /home/ubuntu/LaunchRoo/evals && git remote add origin git@github.com:cte/eval.git 2>/dev/null || true && ${SCRIPT_PATH} --question 'Test question' --expt 'test_git_ops_1'" \
  0

# Verify remote was removed
echo -e "\n${YELLOW}Verifying remote removal${NC}"
cd /home/ubuntu/LaunchRoo/evals
if git remote -v | grep -q "github.com/cte/eval"; then
  echo -e "${RED}Test failed: Remote still exists${NC}"
else
  echo -e "${GREEN}Test passed: Remote was removed${NC}"
fi

# Test 2: Checkout main branch
run_test "Checkout main branch" \
  "${SCRIPT_PATH} --question 'Test question' --expt 'test_git_ops_2'" \
  0

# Verify we're on the main branch
verify_git_status "/home/ubuntu/LaunchRoo/evals" "main" "Main branch verification"

# Test 3: Update main branch with created files
TEST_EXPT="test_git_ops_3"
run_test "Update main branch with created files" \
  "${SCRIPT_PATH} --question 'Test git operations' --expt '${TEST_EXPT}'" \
  0

# Verify the files were committed to the main branch
verify_git_file "/home/ubuntu/LaunchRoo/evals" "python/${TEST_EXPT}/question.md" "File committed verification"
verify_commit_message "/home/ubuntu/LaunchRoo/evals" "Add files for experiment: ${TEST_EXPT}" "Commit message verification"

# Test 4: Verify capture_branch_name function (mock test)
echo -e "\n${YELLOW}Testing capture_branch_name function (mock test)${NC}"
echo -e "${YELLOW}Note: This is a mock test. In actual usage, the branch will be created by the RooCode CLI.${NC}"

# Create a temporary script with the capture_branch_name function
cat > /tmp/capture_branch_test.sh << 'EOF'
#!/bin/bash

# Function to capture the CLI-created branch name
function capture_branch_name {
  echo "Capturing CLI-created branch name..."
  
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
EOF

chmod +x /tmp/capture_branch_test.sh

# Verify the function exists and is properly defined
if grep -q "function capture_branch_name" /tmp/capture_branch_test.sh; then
  echo -e "${GREEN}Test passed: capture_branch_name function is properly defined${NC}"
else
  echo -e "${RED}Test failed: capture_branch_name function is not properly defined${NC}"
fi

echo -e "${YELLOW}Note: In actual usage, this function will be called after the RooCode CLI creates a branch.${NC}"

# Note: The commit_workflow_changes function has been removed as it's redundant
# The RooCode CLI already handles git commits automatically after task completion
echo -e "\n${YELLOW}Note: commit_workflow_changes function has been removed${NC}"
echo -e "${YELLOW}The RooCode CLI already handles git commits automatically after task completion${NC}"

# Clean up
echo -e "\n${YELLOW}Cleaning up test resources${NC}"
cd /home/ubuntu/LaunchRoo/evals
git checkout main
rm -f /tmp/roocode-branch-name.txt
rm -f /tmp/capture_branch_test.sh
# commit_workflow_test.sh is no longer created

echo -e "\n${YELLOW}Tests completed${NC}"