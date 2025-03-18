#!/usr/bin/env bash
set -euo pipefail

# Format code with ruff
ruff format .

# Run linters with automatic fixes
ruff check --fix .

# Run type checking on the Python code
cd hypothesis-python && pyright src

# Run a minimal set of tests to catch obvious issues
# We're not running the full test suite as that will be done in CI
cd hypothesis-python && python -m pytest -xvs tests/cover/test_testdecorators.py
