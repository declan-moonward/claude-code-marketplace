---
name: pr-create
description: Create a well-structured pull request with summary, test plan, and linked tickets
argument-hint: [TICKET-123]
---

Creating a pull request for the current branch:

1. Run `git log main..HEAD --oneline` to understand all commits
2. Run `git diff main...HEAD` to review the full changeset
3. If `$ARGUMENTS` contains a ticket ID, fetch ticket details for context
4. Draft a PR with:
   - **Title**: concise, under 70 characters, prefixed with ticket ID if provided
   - **Summary**: 2-3 bullet points explaining what changed and why
   - **Test plan**: checklist of manual and automated verification steps
   - **Breaking changes**: note any API or behavior changes
5. Ask for confirmation before creating
6. Create the PR using `gh pr create`
7. Return the PR URL
