---
name: code-review
description: Run a comprehensive code review on the current branch's changes
argument-hint: [--focus=security|performance|style]
---

Starting code review on current branch changes:

1. Run `git diff main...HEAD` to identify all changed files
2. For each changed file, review for:
   - **Security**: credentials, injection risks, auth gaps, OWASP top 10
   - **Performance**: N+1 queries, unnecessary re-renders, missing indexes, large payloads
   - **Style**: naming consistency, dead code, missing types, formatting
   - **Logic**: edge cases, error handling, race conditions
3. Check for test coverage on new/changed code
4. Flag any TODO/FIXME/HACK comments that should be addressed
5. Present findings grouped by severity (critical, warning, info)
6. Suggest specific fixes for each finding with code examples

If `$ARGUMENTS` includes `--focus=`, prioritize that review aspect.
