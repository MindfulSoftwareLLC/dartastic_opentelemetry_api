#!/bin/bash

# Ensure the coverage directory exists
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
