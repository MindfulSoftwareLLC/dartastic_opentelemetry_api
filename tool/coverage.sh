#!/bin/bash

# Always operate from the repo root, wherever the script is invoked from.
cd "$(dirname "$0")/.." || exit 1

# Start from a clean slate: stale coverage JSON from earlier runs gets
# merged by format_coverage and corrupts line data and totals.
rm -rf coverage
mkdir -p coverage

# Run tests with coverage
echo "Running tests with coverage..."
dart test --coverage="coverage"

# Format coverage data
echo "Formatting coverage data..."
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --package=. \
  --report-on=lib \
  --base-directory=. \
  --check-ignore

# Generate LCOV report with better branch detection
echo "Generating coverage report..."
genhtml coverage/lcov.info \
  -o coverage/html \
  --branch-coverage \
  --legend

# Open coverage report in default browser (works on macOS)
echo "Opening coverage report..."
open coverage/html/index.html

# Print coverage statistics
echo "Coverage statistics:"
lcov --summary coverage/lcov.info
