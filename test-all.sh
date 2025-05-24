#!/bin/bash
# test-all.sh - Run all tests for the RooCode Modular System

# Set the color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run a test and report the result
run_test() {
  local test_script=$1
  local test_name=$2
  
  echo -e "${YELLOW}Running $test_name...${NC}"
  
  if bash "$test_script"; then
    echo -e "${GREEN}✓ $test_name passed${NC}"
    return 0
  else
    echo -e "${RED}✗ $test_name failed${NC}"
    return 1
  fi
}

# Print header
echo "==============================================="
echo "  RooCode Modular System Test Suite"
echo "==============================================="
echo ""

# Initialize counters
total_tests=0
passed_tests=0
failed_tests=0

# Run all tests
tests=(
  "test-input-processing.sh:Input Processing Tests"
  "test-file-management.sh:File Management Tests"
  "test-git-operations.sh:Git Operations Tests"
  "test-workflow-execution.sh:Workflow Execution Tests"
  "test-output-files.sh:Output Files Tests"
  "test-output-all-files.sh:Output All Files Tests"
  "test-end-to-end.sh:End-to-End Tests"
)

# Run each test
for test in "${tests[@]}"; do
  IFS=':' read -r script name <<< "$test"
  ((total_tests++))
  
  if run_test "$script" "$name"; then
    ((passed_tests++))
  else
    ((failed_tests++))
  fi
  
  echo ""
done

# Print summary
echo "==============================================="
echo "  Test Summary"
echo "==============================================="
echo -e "Total tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
if [ $failed_tests -gt 0 ]; then
  echo -e "${RED}Failed: $failed_tests${NC}"
  exit_code=1
else
  echo -e "Failed: $failed_tests"
  exit_code=0
fi
echo "==============================================="

# Exit with appropriate code
exit $exit_code