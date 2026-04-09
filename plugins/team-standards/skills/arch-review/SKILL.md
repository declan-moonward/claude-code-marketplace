---
name: arch-review
description: Review a proposed architectural approach or design decision against team standards and existing codebase patterns. Use this skill when the user asks "should I use X or Y", "is this the right approach", "review my architecture", "compare these approaches", "design review", or wants feedback on a technical direction before writing code. Also use when the user describes a planned approach and wants validation, or asks whether something is consistent with how the codebase already works.
argument-hint: [description of approach | "approach A vs approach B"]
---

You are reviewing a proposed architectural decision against the team's coding standards and the patterns already established in the codebase. The goal is to catch misalignment, inconsistency, or over-engineering before any code is written — when it's cheap to change direction.

Your recommendations must be grounded in what the codebase actually does, not theoretical best practices. If the codebase uses a particular pattern consistently, that pattern is the right answer even if a textbook might suggest otherwise.

## Input

The user provides via `$ARGUMENTS` or in their message:
- A description of a proposed approach (e.g., "I'm thinking of using Redux for state management")
- Two approaches to compare (e.g., "should I use context or zustand for this")
- A question about the right pattern to use (e.g., "how should I handle data fetching here")

If the input is vague, ask one clarifying question before proceeding.

## Steps

### 1. Understand the proposal

Restate what the user is proposing in one sentence. Identify:
- What problem they're trying to solve
- What approach they're considering (or the two they want compared)
- What area of the codebase is affected (state management, data fetching, component structure, routing, etc.)

### 2. Read the team standards

Read the project's CLAUDE.md file to understand the team's established rules. Pay attention to:
- Required patterns (e.g., functional components only, TanStack Query for data fetching, react-hook-form + zod for forms)
- Naming conventions (kebab-case files, PascalCase components, camelCase variables)
- File organization rules (200-line limit, single responsibility, hooks in hooks/ folder)
- Performance guidelines (componentize to minimize re-renders, modularize)

### 3. Scan the codebase for established patterns

This is the critical step. Don't just check the standards document — look at what the code actually does:
- Use Grep and Glob to find how the relevant pattern is currently implemented across the codebase
- Count occurrences — if 15 files use pattern A and 1 uses pattern B, the codebase has a clear preference
- Read 2-3 representative examples of the existing pattern to understand nuances
- Note any inconsistencies in the current codebase (they exist — acknowledge them honestly)

The evidence you gather here is what makes your review credible rather than generic.

### 4. Evaluate the proposal

Assess the proposed approach against what you found. For each criterion, give a clear verdict:

- **Standards compliance**: Does it follow CLAUDE.md rules? (pass/concern/fail)
- **Pattern consistency**: Does it match how the codebase already handles similar problems? (pass/concern/fail)
- **Complexity**: Is this the simplest approach that meets the need, or is it over-engineered? (pass/concern/fail)
- **Scalability**: Will this approach hold up as the feature grows, or will it need rework? (pass/concern/fail)

If the user asked to compare two approaches, evaluate both and build a trade-off matrix.

### 5. Output the review

For a **single approach review**:

```markdown
## Architecture Review: [Brief Description]

### Proposal
[One sentence restating what was proposed]

### Assessment

| Criterion | Verdict | Notes |
|-----------|---------|-------|
| Standards compliance | pass/concern/fail | [Brief explanation] |
| Pattern consistency | pass/concern/fail | [Brief explanation with file references] |
| Complexity | pass/concern/fail | [Brief explanation] |
| Scalability | pass/concern/fail | [Brief explanation] |

### Pattern Analysis
[What the codebase currently does in this area, with file paths as evidence]

### Recommendation
[Clear recommendation: proceed as proposed, modify the approach, or consider an alternative. Explain why in 2-3 sentences.]

### Suggested Changes (if any)
[Specific modifications to the proposed approach, if the recommendation isn't to proceed as-is]
```

For a **comparison review**, replace the Assessment section with:

```markdown
### Comparison

| Criterion | Approach A | Approach B |
|-----------|-----------|-----------|
| Standards compliance | verdict + note | verdict + note |
| Pattern consistency | verdict + note | verdict + note |
| Complexity | verdict + note | verdict + note |
| Scalability | verdict + note | verdict + note |

### Recommendation
[Which approach to use and why, grounded in the evidence above]
```

## Rules

- Every recommendation must cite at least one file path from the codebase as evidence — "the codebase does X" without a file reference is just an opinion
- If the codebase is inconsistent about a pattern, say so honestly and recommend which of the existing approaches to follow going forward
- Don't recommend introducing new libraries or abstractions unless the existing codebase clearly has a gap — prefer what's already there
- A "concern" verdict means it's not wrong but worth thinking about. A "fail" means it conflicts with an established standard or pattern
- Keep the review concise — this should take 2 minutes to read, not 10. Developers want a verdict, not an essay
- If the proposal is solid and aligns with everything, say so briefly. Don't manufacture concerns to seem thorough
