#!/bin/bash
# test-end-to-end.sh - End-to-end test for the RooCode Modular System

# Set the color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a file exists
check_file_exists() {
  local file=$1
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓ File exists: $file${NC}"
    return 0
  else
    echo -e "${RED}✗ File does not exist: $file${NC}"
    return 1
  fi
}

# Function to check if a directory exists
check_directory_exists() {
  local dir=$1
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✓ Directory exists: $dir${NC}"
    return 0
  else
    echo -e "${RED}✗ Directory does not exist: $dir${NC}"
    return 1
  fi
}

# Function to check if a file contains a string
check_file_contains() {
  local file=$1
  local string=$2
  if grep -q "$string" "$file"; then
    echo -e "${GREEN}✓ File $file contains: $string${NC}"
    return 0
  else
    echo -e "${RED}✗ File $file does not contain: $string${NC}"
    return 1
  fi
}

# Print header
echo "==============================================="
echo "  RooCode Modular System End-to-End Test"
echo "==============================================="
echo ""

# Create a temporary directory for the test
TEST_DIR=$(mktemp -d)
echo "Creating temporary test directory: $TEST_DIR"

# Create test files
echo "Creating test files..."
echo "def add(a, b):" > "$TEST_DIR/calculator.py"
echo "    return a + b" >> "$TEST_DIR/calculator.py"
echo "" >> "$TEST_DIR/calculator.py"
echo "def subtract(a, b):" >> "$TEST_DIR/calculator.py"
echo "    return a - b" >> "$TEST_DIR/calculator.py"

echo "import unittest" > "$TEST_DIR/test_calculator.py"
echo "from calculator import add, subtract" >> "$TEST_DIR/test_calculator.py"
echo "" >> "$TEST_DIR/test_calculator.py"
echo "class TestCalculator(unittest.TestCase):" >> "$TEST_DIR/test_calculator.py"
echo "    def test_add(self):" >> "$TEST_DIR/test_calculator.py"
echo "        self.assertEqual(add(1, 2), 3)" >> "$TEST_DIR/test_calculator.py"
echo "    def test_subtract(self):" >> "$TEST_DIR/test_calculator.py"
echo "        self.assertEqual(subtract(3, 1), 2)" >> "$TEST_DIR/test_calculator.py"
echo "" >> "$TEST_DIR/test_calculator.py"
echo "if __name__ == '__main__':" >> "$TEST_DIR/test_calculator.py"
echo "    unittest.main()" >> "$TEST_DIR/test_calculator.py"

# Generate a unique experiment name
EXPT_NAME="test_end_to_end_$(date +%s)"
echo "Experiment name: $EXPT_NAME"

# Generate a unique session ID
SESSION_ID="test_session_$(date +%s)"
echo "Session ID: $SESSION_ID"

# Run the RooCode Modular System
echo -e "${YELLOW}Running RooCode Modular System...${NC}"
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "$EXPT_NAME" \
  --files "$TEST_DIR/calculator.py:calculator.py,$TEST_DIR/test_calculator.py:test_calculator.py" \
  --prompt "Create a calculator with add, subtract, multiply, and divide functions." \
  --output "calculator.py,test_calculator.py" \
  --session "$SESSION_ID"

# Check if the command was successful
if [ $? -ne 0 ]; then
  echo -e "${RED}✗ RooCode Modular System failed${NC}"
  rm -rf "$TEST_DIR"
  exit 1
fi

# Check if the experiment directory was created
EXPT_DIR="/home/ubuntu/LaunchRoo/evals/python/$EXPT_NAME"
check_directory_exists "$EXPT_DIR" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the question.md file was created
check_file_exists "$EXPT_DIR/question.md" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the outline.md file was created
check_file_exists "$EXPT_DIR/outline.md" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the calculator.py file was copied
check_file_exists "$EXPT_DIR/calculator.py" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the test_calculator.py file was copied
check_file_exists "$EXPT_DIR/test_calculator.py" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the question.md file contains the question
check_file_contains "$EXPT_DIR/question.md" "How do I implement a calculator in Python?" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the outline.md file contains the prompt
check_file_contains "$EXPT_DIR/outline.md" "Create a calculator with add, subtract, multiply, and divide functions." || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the output directory was created
OUTPUT_DIR="/home/ubuntu/LaunchRoo/output/session_${SESSION_ID}_/branch_main_"
check_directory_exists "$OUTPUT_DIR" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the calculator.py file was copied to the output directory
check_file_exists "$OUTPUT_DIR/calculator.py" || { rm -rf "$TEST_DIR"; exit 1; }

# Check if the test_calculator.py file was copied to the output directory
check_file_exists "$OUTPUT_DIR/test_calculator.py" || { rm -rf "$TEST_DIR"; exit 1; }

# Clean up
echo "Cleaning up..."
rm -rf "$TEST_DIR"

# Print success message
echo ""
echo -e "${GREEN}✓ End-to-end test passed${NC}"
echo ""

exit 0