#!/usr/bin/env bash
set -euo pipefail

echo "Installing Hypothesis development dependencies..."

# Use --no-deps for subsequent installations to avoid dependency conflicts
# Use --ignore-installed to avoid trying to uninstall system packages

echo "Installing test dependencies..."
pip install --ignore-installed -r requirements/test.txt

echo "Installing coverage dependencies..."
pip install --ignore-installed --no-deps -r requirements/coverage.txt

# Install known problematic packages individually with --no-deps
echo "Installing potentially problematic packages individually..."
pip install --ignore-installed wheel setuptools pip

echo "Installing tools dependencies..."
# Skip installation if it fails - many of these are optional for basic development
pip install --ignore-installed --no-deps -r requirements/tools.txt || echo "Warning: Some tool dependencies could not be installed"

echo "Installing hypothesis package in development mode..."
pip install --ignore-installed -e hypothesis-python/[all]

echo "Setup completed successfully!"
