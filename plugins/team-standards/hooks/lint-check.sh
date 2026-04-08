#!/usr/bin/env bash
# Hook: post-file-edit
# Runs a quick lint check after Claude edits a file.
# Exit 0 = pass, non-zero = block and show output to Claude.

FILE="$1"
EXTENSION="${FILE##*.}"
LINT_EXIT=0

case "$EXTENSION" in
  ts|tsx|js|jsx)
    if command -v npx &> /dev/null && [ -f "$(git rev-parse --show-toplevel 2>/dev/null)/node_modules/.bin/eslint" ]; then
      npx eslint --no-error-on-unmatched-pattern --max-warnings=0 "$FILE" 2>&1
      LINT_EXIT=$?
    fi
    ;;
  py)
    if command -v ruff &> /dev/null; then
      ruff check "$FILE" 2>&1
      LINT_EXIT=$?
    elif command -v flake8 &> /dev/null; then
      flake8 "$FILE" 2>&1
      LINT_EXIT=$?
    fi
    ;;
  go)
    if command -v golangci-lint &> /dev/null; then
      golangci-lint run "$FILE" 2>&1
      LINT_EXIT=$?
    fi
    ;;
esac

exit $LINT_EXIT
