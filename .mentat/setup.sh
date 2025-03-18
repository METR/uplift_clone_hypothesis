#!/usr/bin/env bash
set -euo pipefail

# Install dependencies for Python components
pip install -r requirements/test.txt
pip install -r requirements/coverage.txt
pip install -r requirements/tools.txt

# Install hypothesis package in development mode
pip install -e hypothesis-python/[all]
