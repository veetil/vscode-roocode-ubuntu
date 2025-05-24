#!/bin/bash
# test-output-files.sh - Test the output file copying functionality of roocode-modular.sh

# Set up test environment
TEST_DIR="/tmp/roocode-test-$(date +%s)"
EVALS_DIR="/home/ubuntu/LaunchRoo/evals"
PYTHON_DIR="${EVALS_DIR}/python"
OUTPUT_DIR="/home/ubuntu/LaunchRoo/output"

# Create test directories
mkdir -p "${TEST_DIR}"
mkdir -p "${EVALS_DIR}"
mkdir -p "${PYTHON_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Create test files
echo "Test file 1 content" > "${TEST_DIR}/test1.txt"
echo "Test file 2 content" > "${TEST_DIR}/test2.txt"
mkdir -p "${TEST_DIR}/subdir"
echo "Test file 3 content" > "${TEST_DIR}/subdir/test3.txt"

# Set up test parameters
TEST_EXPT="test_output_$(date +%s)"
TEST_QUESTION="Test question for output file copying"
TEST_SESSION="test_session_$(date +%s)"

# Create a fake git repository for testing
cd "${EVALS_DIR}"
if [ ! -d ".git" ]; then
    git init
    git config --global user.email "test@example.com"
    git config --global user.name "Test User"
    touch README.md
    git add README.md
    git commit -m "Initial commit"
fi

# Create a fake branch name file
echo "test-branch" > "/tmp/roocode-branch-name.txt"

# Run the script with the test parameters
echo "Running roocode-modular.sh with output file parameters..."
# Use the full path to the script
/home/ubuntu/LaunchRoo/roocode-modular.sh \
    --question "${TEST_QUESTION}" \
    --expt "${TEST_EXPT}" \
    --files "${TEST_DIR}/test1.txt:test1.txt,${TEST_DIR}/test2.txt:test2.txt,${TEST_DIR}/subdir/test3.txt:subdir/test3.txt" \
    --output "test1.txt,subdir" \
    --session "${TEST_SESSION}"

# Verify the output folder was created
SANITIZED_SESSION=$(echo "${TEST_SESSION}" | tr -c '[:alnum:]_-' '_')

# Get the actual branch name from the script output
cd "${EVALS_DIR}"
ACTUAL_BRANCH=$(git branch --show-current)
SANITIZED_BRANCH=$(echo "${ACTUAL_BRANCH}" | tr -c '[:alnum:]_-' '_')

# The output folder structure is now session_<session_id>/branch_<branchname>
SESSION_FOLDER="session_${SANITIZED_SESSION}"
BRANCH_FOLDER="branch_${SANITIZED_BRANCH}"
OUTPUT_FOLDER="${OUTPUT_DIR}/${SESSION_FOLDER}/${BRANCH_FOLDER}"

# Print the actual output folder for debugging
echo "Expected output folder: ${OUTPUT_FOLDER}"
ls -la "${OUTPUT_DIR}"
if [ -d "${OUTPUT_DIR}/${SESSION_FOLDER}" ]; then
    echo "Session folder contents:"
    ls -la "${OUTPUT_DIR}/${SESSION_FOLDER}"
fi

echo "Checking output folder: ${OUTPUT_FOLDER}"
if [ ! -d "${OUTPUT_FOLDER}" ]; then
    echo "ERROR: Output folder was not created"
    exit 1
fi

# Verify the output files were copied correctly
echo "Checking output files..."
if [ ! -f "${OUTPUT_FOLDER}/test1.txt" ]; then
    echo "ERROR: test1.txt was not copied to the output folder"
    exit 1
fi

if [ ! -d "${OUTPUT_FOLDER}/subdir" ]; then
    echo "ERROR: subdir was not copied to the output folder"
    exit 1
fi

if [ ! -f "${OUTPUT_FOLDER}/subdir/test3.txt" ]; then
    echo "ERROR: subdir/test3.txt was not copied to the output folder"
    exit 1
fi

# Verify the content of the copied files
echo "Checking file content..."
if [ "$(cat "${OUTPUT_FOLDER}/test1.txt")" != "Test file 1 content" ]; then
    echo "ERROR: Content of test1.txt is incorrect"
    exit 1
fi

if [ "$(cat "${OUTPUT_FOLDER}/subdir/test3.txt")" != "Test file 3 content" ]; then
    echo "ERROR: Content of subdir/test3.txt is incorrect"
    exit 1
fi

# Clean up
echo "Cleaning up test files..."
rm -rf "${TEST_DIR}"
rm -rf "${PYTHON_DIR}/${TEST_EXPT}"
rm -rf "${OUTPUT_FOLDER}"
rm -f "/tmp/roocode-branch-name.txt"

echo "Test completed successfully!"
exit 0