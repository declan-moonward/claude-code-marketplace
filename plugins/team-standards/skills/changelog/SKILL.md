---
name: changelog
description: Generate client-friendly, categorized release notes from git history
argument-hint: [date range | branch comparison | tag comparison]
---

You are a release notes generator. Produce client-friendly, categorized release notes from git history.

## Input

The user may provide via `$ARGUMENTS`:
- A date range (e.g., "this week", "last 2 weeks", "since March 1")
- A branch comparison (e.g., "main..dev")
- A tag comparison (e.g., "v1.2.0..v1.3.0")

If no scope is provided, default to commits on the current branch since the last merge to main.

## Steps

1. **Gather git history** — Run the appropriate git commands:
   - `git log <range> --format="%h %ci %s" --no-merges` for commit messages
   - `git diff <range> --stat` for scope/size of changes
   - Convert any relative dates to absolute dates for the git `--since`/`--until` flags

2. **Categorize commits** — Group each commit into one of these categories based on its message and context:
   - **New Features** — New user-facing functionality
   - **Improvements** — Enhancements to existing features, UX polish, refactors with user impact
   - **Bug Fixes** — Fixes to broken behavior
   - Collapse QA, hotfix, and build-error commits into a single line under Bug Fixes (e.g., "QA fixes across multiple areas (N patches)")
   - Omit merge commits entirely

3. **Rewrite for readability** — For each item:
   - Lead with a **bold short label** followed by an em dash and a one-sentence description
   - Use plain, client-friendly language — no ticket IDs, no technical jargon
   - Focus on *what changed for the user*, not implementation details
   - Combine related commits into a single entry when they describe the same feature

4. **Output as markdown** using this structure:

```
Dev Updates — <date range or comparison>

<N> commits merged to <branch>

---

### New Features

- **Feature name** — One-sentence description of what users can now do

### Improvements

- **Area improved** — One-sentence description of what got better

### Bug Fixes

- **Fixed** — Description
- QA fixes across multiple areas (N patches)

---

<N> commits, <files changed> files changed
```

## Rules

- If a category has no entries, omit it entirely
- Keep each bullet to one sentence — two max if the feature is complex
- Do not include commit hashes, PR numbers, or ticket IDs in the output
- Do not include raw commit messages — always rewrite them
- Order entries within each category by significance, most impactful first
- The header and footer should reflect the actual scope (date range, commit count, branch)
