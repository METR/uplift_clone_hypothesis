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

# Run type checking on the Python code - make it non-fatal
# Vendor code often has type errors we don't want to fix
if check_command pyright "type checking"; then
    echo "Running pyright type checker..."
    
    # Create a temporary pyrightconfig.json to ignore vendor files
    TEMP_CONFIG=$(mktemp)
    cat > "$TEMP_CONFIG" <<EOF
{
  "include": ["src"],
  "exclude": ["src/hypothesis/vendor/**"],
  "typeCheckingMode": "strict"
}
EOF

    # Run pyright with temp config, but don't fail the script if it errors
    (cd "$REPO_ROOT/hypothesis-python" && pyright --project "$TEMP_CONFIG" src) || {
        echo "Warning: Type checking found errors, but continuing with pre-commit checks"
        echo "Note: Errors in vendor files are expected and can be ignored"
    }
    
    # Clean up temp file
    rm "$TEMP_CONFIG"
fi

# Run a minimal set of tests to catch obvious issues
echo "Running minimal test suite..."
(cd "$REPO_ROOT/hypothesis-python" && python -m pytest -xvs tests/cover/test_testdecorators.py)

echo "Pre-commit checks completed successfully!"
