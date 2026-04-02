---
name: ticket-workflow
description: Start work on a Jira ticket - creates branch, sets up context
argument-hint: TICKET-123
---

Starting work on ticket $ARGUMENTS:

1. Fetch ticket details from Jira (summary, description, acceptance criteria)
2. Create a feature branch: `feature/$ARGUMENTS-[brief-description]`
3. Read the acceptance criteria and identify key requirements
4. Create a brief implementation plan with estimated steps
5. Ask for confirmation before starting implementation
