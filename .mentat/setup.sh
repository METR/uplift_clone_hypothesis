#!/usr/bin/env bash
set -euo pipefail

echo "Installing Hypothesis development dependencies..."

# Find the appropriate pip command
PIP_CMD=""
for cmd in pip3 pip pip3.10 pip3.11 pip3.12; do
    if command -v "$cmd" &> /dev/null; then
        PIP_CMD="$cmd"
        echo "Using pip: $PIP_CMD"
        break
    fi
done

if [ -z "$PIP_CMD" ]; then
    echo "Error: No pip command found. Cannot install dependencies."
    exit 1
fi

# Find the Python executable that corresponds to the pip we're using
if [[ "$PIP_CMD" == pip3* ]]; then
    PYTHON_CMD="${PIP_CMD/pip/python}"
else
    PYTHON_CMD="python3"
    if ! command -v "$PYTHON_CMD" &> /dev/null; then
        PYTHON_CMD="python"
    fi
fi

echo "Using Python interpreter: $PYTHON_CMD"

# Use --no-deps for subsequent installations to avoid dependency conflicts
# Use --ignore-installed to avoid trying to uninstall system packages

echo "Installing test dependencies..."
$PIP_CMD install --ignore-installed -r requirements/test.txt

echo "Installing coverage dependencies..."
$PIP_CMD install --ignore-installed --no-deps -r requirements/coverage.txt

# Install known problematic packages individually with --no-deps
echo "Installing potentially problematic packages individually..."
$PIP_CMD install --ignore-installed wheel setuptools pip

echo "Installing tools dependencies..."
# Skip installation if it fails - many of these are optional for basic development
$PIP_CMD install --ignore-installed --no-deps -r requirements/tools.txt || echo "Warning: Some tool dependencies could not be installed"

echo "Installing hypothesis package in development mode..."
$PIP_CMD install --ignore-installed -e hypothesis-python/[all]

# Verify the installation
if command -v "$PYTHON_CMD" &> /dev/null; then
    echo "Verifying installation..."
    $PYTHON_CMD -c "import hypothesis; print(f'Successfully installed hypothesis version {hypothesis.__version__}')"
else
    echo "Warning: Could not verify installation (Python interpreter not found)"
fi

echo "Setup completed successfully!"
