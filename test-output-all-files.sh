#!/bin/bash
# test-output-all-files.sh - Test the --output "*" feature of roocode-modular.sh

# Set up test environment
TEST_TIMESTAMP=$(date +%s)
TEST_DIR="/tmp/roocode-test-${TEST_TIMESTAMP}"
EVALS_DIR="/home/ubuntu/LaunchRoo/evals"
PYTHON_DIR="${EVALS_DIR}/python"
OUTPUT_DIR="/home/ubuntu/LaunchRoo/output"
TEST_EXPT="test_output_all_${TEST_TIMESTAMP}"
TEST_SESSION="test_session_${TEST_TIMESTAMP}"

echo "Setting up test environment..."

# Create test directories
mkdir -p "${TEST_DIR}"
mkdir -p "${TEST_DIR}/subdir"
mkdir -p "${TEST_DIR}/nested/subdir"
mkdir -p "${EVALS_DIR}"
mkdir -p "${PYTHON_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Create test files
echo "Test file 1 content" > "${TEST_DIR}/test1.txt"
echo "Test file 2 content" > "${TEST_DIR}/test2.txt"
echo "Test file 3 content" > "${TEST_DIR}/subdir/test3.txt"
echo "Test file 4 content" > "${TEST_DIR}/nested/subdir/test4.txt"
echo "Test Python file" > "${TEST_DIR}/${TEST_EXPT}.py"
echo "Test Python test file" > "${TEST_DIR}/${TEST_EXPT}_test.py"

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

# Run the script with --output "*"
echo "Running roocode-modular.sh with --output \"*\"..."
/home/ubuntu/LaunchRoo/roocode-modular.sh \
    --question "Test question for output all files" \
    --expt "${TEST_EXPT}" \
    --files "${TEST_DIR}/test1.txt:test1.txt,${TEST_DIR}/test2.txt:test2.txt,${TEST_DIR}/subdir/test3.txt:subdir/test3.txt,${TEST_DIR}/nested/subdir/test4.txt:nested/subdir/test4.txt,${TEST_DIR}/${TEST_EXPT}.py:${TEST_EXPT}.py,${TEST_DIR}/${TEST_EXPT}_test.py:${TEST_EXPT}_test.py" \
    --output "*" \
    --session "${TEST_SESSION}"

# Get the actual branch name from the script output
cd "${EVALS_DIR}"
ACTUAL_BRANCH=$(git branch --show-current)
SANITIZED_BRANCH=$(echo "${ACTUAL_BRANCH}" | tr -c '[:alnum:]_-' '_')
SANITIZED_SESSION=$(echo "${TEST_SESSION}" | tr -c '[:alnum:]_-' '_')

# The output folder structure is now session_<session_id>/branch_<branchname>
SESSION_FOLDER="session_${SANITIZED_SESSION}"
BRANCH_FOLDER="branch_${SANITIZED_BRANCH}"
OUTPUT_FOLDER="${OUTPUT_DIR}/${SESSION_FOLDER}/${BRANCH_FOLDER}"

echo "Checking output folder: ${OUTPUT_FOLDER}"

# Verify the output folder was created
if [ ! -d "${OUTPUT_FOLDER}" ]; then
    echo "ERROR: Output folder was not created"
    echo "Expected: ${OUTPUT_FOLDER}"
    ls -la "${OUTPUT_DIR}"
    if [ -d "${OUTPUT_DIR}/${SESSION_FOLDER}" ]; then
        echo "Session folder contents:"
        ls -la "${OUTPUT_DIR}/${SESSION_FOLDER}"
    fi
    exit 1
fi

# Verify all files were copied
echo "Checking output files..."

# List of files to check
FILES_TO_CHECK=(
    "test1.txt"
    "test2.txt"
    "subdir/test3.txt"
    "nested/subdir/test4.txt"
    "${TEST_EXPT}.py"
    "${TEST_EXPT}_test.py"
    "question.md"
)

# Check each file
for file in "${FILES_TO_CHECK[@]}"; do
    if [ ! -e "${OUTPUT_FOLDER}/${file}" ]; then
        echo "ERROR: ${file} was not copied to the output folder"
        exit 1
    fi
    echo "✓ ${file} exists in output folder"
done

# Verify the content of some files
echo "Checking file content..."
if [ "$(cat ${OUTPUT_FOLDER}/test1.txt)" != "Test file 1 content" ]; then
    echo "ERROR: Content of test1.txt in output folder is incorrect"
    exit 1
fi

if [ "$(cat ${OUTPUT_FOLDER}/nested/subdir/test4.txt)" != "Test file 4 content" ]; then
    echo "ERROR: Content of nested/subdir/test4.txt in output folder is incorrect"
    exit 1
fi

# Clean up test files
echo "Cleaning up test files..."
rm -rf "${TEST_DIR}"

echo "Test completed successfully!"
exit 0