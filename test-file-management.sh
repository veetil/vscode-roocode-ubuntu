#!/bin/bash
# test-file-management.sh - Test script for file management component

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

# Function to verify file content
function verify_file_content {
  local file_path="$1"
  local expected_content="$2"
  local test_name="$3"
  
  echo -e "\n${YELLOW}Verifying file content: ${test_name}${NC}"
  echo "File: $file_path"
  
  if [[ ! -f "$file_path" ]]; then
    echo -e "${RED}Test failed: File does not exist${NC}"
    return 1
  fi
  
  local actual_content=$(cat "$file_path")
  
  echo "Expected content: $expected_content"
  echo "Actual content: $actual_content"
  
  if [[ "$actual_content" == "$expected_content" ]]; then
    echo -e "${GREEN}Test passed: Content matches${NC}"
    return 0
  else
    echo -e "${RED}Test failed: Content does not match${NC}"
    return 1
  fi
}

# Create test files and directories
echo -e "\n${YELLOW}Setting up test environment${NC}"
mkdir -p test_files
echo "Test content 1" > test_files/test1.txt
echo "Test content 2" > test_files/test2.txt
mkdir -p test_files/subdir
echo "Test content 3" > test_files/subdir/test3.txt

# Test cases
echo -e "\n${YELLOW}Starting tests for file management${NC}"

# Test 1: Save question to question.md
TEST_QUESTION="This is a test question"
TEST_EXPT="test_file_mgmt_1"
run_test "Save question to question.md" \
  "./roocode-modular.sh --question '${TEST_QUESTION}' --expt '${TEST_EXPT}'" \
  0

# Verify question.md content
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/question.md" \
  "${TEST_QUESTION}" \
  "question.md content verification"

# Test 2: Save prompt to outline.md
TEST_PROMPT="This is a test prompt"
TEST_EXPT="test_file_mgmt_2"
run_test "Save prompt to outline.md" \
  "./roocode-modular.sh --question 'Test question' --expt '${TEST_EXPT}' --prompt '${TEST_PROMPT}'" \
  0

# Verify outline.md content
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/outline.md" \
  "${TEST_PROMPT}" \
  "outline.md content verification"

# Test 3: Copy a single file
TEST_EXPT="test_file_mgmt_3"
run_test "Copy a single file" \
  "./roocode-modular.sh --question 'Test question' --expt '${TEST_EXPT}' --files 'test_files/test1.txt:test1.txt'" \
  0

# Verify copied file content
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/test1.txt" \
  "Test content 1" \
  "Copied file content verification"

# Test 4: Copy multiple files
TEST_EXPT="test_file_mgmt_4"
run_test "Copy multiple files" \
  "./roocode-modular.sh --question 'Test question' --expt '${TEST_EXPT}' --files 'test_files/test1.txt:test1.txt,test_files/test2.txt:test2.txt'" \
  0

# Verify copied files content
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/test1.txt" \
  "Test content 1" \
  "First copied file content verification"
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/test2.txt" \
  "Test content 2" \
  "Second copied file content verification"

# Test 5: Copy file to subdirectory
TEST_EXPT="test_file_mgmt_5"
run_test "Copy file to subdirectory" \
  "./roocode-modular.sh --question 'Test question' --expt '${TEST_EXPT}' --files 'test_files/test1.txt:subdir/test1.txt'" \
  0

# Verify copied file content in subdirectory
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/subdir/test1.txt" \
  "Test content 1" \
  "Copied file in subdirectory content verification"

# Test 6: All features together
TEST_EXPT="test_file_mgmt_6"
TEST_QUESTION="Combined test question"
TEST_PROMPT="Combined test prompt"
run_test "All features together" \
  "./roocode-modular.sh --question '${TEST_QUESTION}' --expt '${TEST_EXPT}' --prompt '${TEST_PROMPT}' --files 'test_files/test1.txt:test1.txt,test_files/test2.txt:subdir/test2.txt'" \
  0

# Verify all files
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/question.md" \
  "${TEST_QUESTION}" \
  "Combined question.md verification"
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/outline.md" \
  "${TEST_PROMPT}" \
  "Combined outline.md verification"
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/test1.txt" \
  "Test content 1" \
  "Combined first file verification"
verify_file_content "/home/ubuntu/LaunchRoo/evals/python/${TEST_EXPT}/subdir/test2.txt" \
  "Test content 2" \
  "Combined second file verification"

# Test 7: Error handling - non-existent source file
TEST_EXPT="test_file_mgmt_error"
run_test "Error handling - non-existent source file" \
  "./roocode-modular.sh --question 'Test question' --expt '${TEST_EXPT}' --files 'nonexistent_file.txt:test.txt'" \
  1

# Clean up
echo -e "\n${YELLOW}Cleaning up test resources${NC}"
rm -rf test_files
rm -rf /home/ubuntu/LaunchRoo/evals/python/test_file_mgmt_*

echo -e "\n${YELLOW}Tests completed${NC}"