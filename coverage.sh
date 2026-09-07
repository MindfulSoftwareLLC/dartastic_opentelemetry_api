#!/bin/bash

# Always operate from the repo root, wherever the script is invoked from.
cd "$(dirname "$0")/.." || exit 1

# Restrict the run to test/unit with --unit. The SDK's coverage.sh takes the
# same flag, so `coverage` and `coverage_unit_only` mean the same thing in
# both packages. This package currently only has test/unit, so --unit is a
# no-op here, but the interface stays consistent.
TEST_PATH="test"
while [[ $# -gt 0 ]]; do
  case $1 in
    --unit)
      TEST_PATH="test/unit"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--unit]"
      echo "  --unit    Restrict the run to test/unit."
      exit 1
      ;;
  esac
done

# Start from a clean slate: stale coverage JSON from earlier runs gets
# merged by format_coverage and corrupts line data and totals.
rm -rf coverage
mkdir -p coverage

# Run tests with coverage
echo "Running tests with coverage..."
dart test --coverage="coverage" "$TEST_PATH"

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

# Open the report in the default browser on macOS (CI runs Linux, where
# `open` does not exist and would fail the script under set -e).
if [[ "$OSTYPE" == darwin* ]]; then
  echo "Opening coverage report..."
  open coverage/html/index.html
fi

# Print coverage statistics
echo "Coverage statistics:"
lcov --summary coverage/lcov.info
