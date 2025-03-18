#!/usr/bin/env bash
set -euo pipefail

echo "Running pre-commit checks..."
REPO_ROOT=$(git rev-parse --show-toplevel)

# Check if commands exist before using them
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Warning: $1 is not installed, skipping $2"
        return 1
    fi
    return 0
}

# Format code with ruff if available
if check_command ruff "code formatting"; then
    echo "Running ruff formatter..."
    ruff format .
fi

# Run linters with automatic fixes if available
if check_command ruff "linting"; then
    echo "Running ruff linter with auto-fixes..."
    ruff check --fix .
fi

# Run type checking on the Python code
if check_command pyright "type checking"; then
    echo "Running pyright type checker..."
    (cd "$REPO_ROOT/hypothesis-python" && pyright src)
fi

# Run a minimal set of tests to catch obvious issues
echo "Running minimal test suite..."
(cd "$REPO_ROOT/hypothesis-python" && python -m pytest -xvs tests/cover/test_testdecorators.py)

echo "Pre-commit checks completed successfully!"
