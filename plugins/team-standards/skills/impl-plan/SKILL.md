---
name: impl-plan
description: Create a detailed implementation plan for a feature, ticket, or task. Use this skill when the user asks to plan a feature, break down a ticket, figure out what files need to change, create an implementation strategy, or asks "how should I implement this". Also use when the user says "plan this", "what's the approach for", "break this down", "scope this out", or provides a Jira ticket and wants to understand the work involved before coding.
argument-hint: [TICKET-123 | feature description]
---

You are creating a detailed, codebase-grounded implementation plan. The goal is to give the developer a clear roadmap before they write any code — what files to touch, in what order, and what to watch out for. Plans that aren't grounded in the actual codebase are just guesses, so the exploration step is critical.

## Input

The user provides via `$ARGUMENTS`:
- A Jira ticket ID (e.g., `PROJ-123`) — fetch details via Jira MCP
- A free-text feature description
- Both a ticket ID and additional context
- Nothing — ask what they'd like to plan

If a ticket ID is provided, fetch the ticket summary, description, and acceptance criteria before proceeding.

## Steps

### 1. Understand the requirement

Clarify what needs to be built. If the input is a ticket, extract:
- What the feature does (user-facing behavior)
- Acceptance criteria or success conditions
- Any constraints mentioned (performance, compatibility, deadlines)

If the input is free-text, restate it back concisely to confirm understanding. If anything is ambiguous, ask one round of clarifying questions before proceeding — don't block on perfection, just catch obvious gaps.

### 2. Explore the codebase

This is the most important step. Read the code to understand:
- **Existing patterns**: How does the codebase handle similar features today? What conventions are used for state management, data fetching, routing, component structure?
- **Reusable code**: Are there utilities, hooks, components, or services that already do part of what's needed? List them with file paths.
- **Entry points**: Where does the new feature plug in? Which existing files need modification vs. which are new?

Use Glob to find related files, Grep to search for similar patterns, and Read to understand the relevant code. Don't skim — actually read the files that matter.

### 3. Map the affected files

For every file that needs to change, document:
- The file path
- Whether it's a new file or a modification
- A 1-2 sentence description of what changes

Present this as a table:

```
| File | Action | Changes |
|------|--------|---------|
| src/components/user-profile.tsx | Modify | Add edit button and wire to new edit form |
| src/hooks/use-user-profile.ts | New | Custom hook for profile CRUD operations |
```

### 4. Define implementation order

Number the steps in the order they should be implemented. Group related changes and explain why the order matters — what depends on what.

Each step should be a concrete, completable unit of work. Not "implement the feature" but "create the API hook that fetches user profile data." A developer should be able to pick up any step and know exactly what to do.

### 5. Identify dependencies and risks

Flag anything that could slow down or derail the implementation:
- **Dependencies**: External APIs, backend changes needed, other team members' work
- **Migration needs**: Database changes, config updates, environment variables
- **Breaking changes**: Will this affect existing functionality? Which tests might break?
- **Unknowns**: Things you couldn't determine from the codebase alone — areas where the developer will need to investigate further or make a judgment call

### 6. Output the plan

Present everything in this structure:

```markdown
## Implementation Plan: [Feature Name]

### Overview
[2-3 sentences: what's being built and why]

### Affected Files
[Table from step 3]

### Existing Code to Reuse
[Bullet list of utilities, hooks, components found in step 2, with file paths]

### Implementation Steps
[Numbered list from step 4]

### Dependencies & Risks
[From step 5]
```

## Rules

- Ground every recommendation in code you actually read — cite file paths and existing patterns as evidence
- Don't propose new abstractions when existing ones in the codebase already handle the need
- If the codebase already has a pattern for something (e.g., TanStack Query for data fetching), the plan should follow it — don't suggest alternatives
- Keep file change descriptions to 1-2 sentences — this is a plan, not a spec
- If the feature is large, suggest how to split it into smaller PRs that can be reviewed independently
- Don't estimate time — focus on what needs to happen, not how long it takes
