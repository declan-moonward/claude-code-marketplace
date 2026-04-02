#!/usr/bin/env bash
# Hook: pre-commit
# Runs before Claude creates a commit. Blocks if checks fail.

set -e

# Check for secrets/credentials in staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for FILE in $STAGED_FILES; do
  # Check for common secret patterns
  if grep -qEi '(api_key|api_secret|password|secret_key|private_key|access_token)\s*[:=]\s*["\x27][^"\x27]{8,}' "$FILE" 2>/dev/null; then
    echo "BLOCKED: Possible secret detected in $FILE"
    echo "Please review and remove any hardcoded credentials."
    exit 1
  fi

  # Check for .env file commits
  if [[ "$FILE" == *.env* ]] || [[ "$FILE" == *credentials* ]]; then
    echo "BLOCKED: Attempting to commit sensitive file: $FILE"
    exit 1
  fi
done

echo "Pre-commit checks passed."
exit 0
