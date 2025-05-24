#!/bin/bash
# test-input-processing.sh - Test script for input processing and experiment folder management

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

# Create a temporary file for testing
echo "Test content" > test_file.txt

# Test cases
echo -e "${YELLOW}Starting tests for input processing and experiment folder management${NC}"

# Test 1: Valid inputs with non-existing experiment folder
run_test "Valid inputs (new experiment folder)" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment_new'" \
  0

# Test 2: Valid inputs with existing experiment folder
# First create the folder if it doesn't exist
mkdir -p /home/ubuntu/LaunchRoo/evals/python/test_experiment_existing
touch /home/ubuntu/LaunchRoo/evals/python/test_experiment_existing/test_experiment_existing.py

run_test "Valid inputs (existing experiment folder)" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment_existing'" \
  0

# Test 3: Missing required argument (question)
run_test "Missing required argument (question)" \
  "./roocode-modular.sh --expt 'test_experiment'" \
  1

# Test 4: Missing required argument (experiment folder)
run_test "Missing required argument (experiment folder)" \
  "./roocode-modular.sh --question 'Test question'" \
  1

# Test 5: Valid inputs with files
run_test "Valid inputs with files" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment_files' --files 'test_file.txt:dest.txt'" \
  0

# Test 6: Invalid file path
run_test "Invalid file path" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment' --files 'nonexistent_file.txt:dest.txt'" \
  1

# Test 7: Invalid file format
run_test "Invalid file format" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment' --files 'test_file.txt'" \
  1

# Test 8: Valid inputs with prompt
run_test "Valid inputs with prompt" \
  "./roocode-modular.sh --question 'Test question' --expt 'test_experiment_prompt' --prompt 'Test prompt'" \
  0

# Clean up
echo -e "\n${YELLOW}Cleaning up test resources${NC}"
rm -f test_file.txt
rm -rf /home/ubuntu/LaunchRoo/evals/python/test_experiment_new
rm -rf /home/ubuntu/LaunchRoo/evals/python/test_experiment_files
rm -rf /home/ubuntu/LaunchRoo/evals/python/test_experiment_prompt

echo -e "\n${YELLOW}Tests completed${NC}"