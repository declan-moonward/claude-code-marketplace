---
name: jira-ticket
description: Fetch and display Jira ticket details, status, and comments
argument-hint: TICKET-123
---

Fetching Jira ticket $ARGUMENTS:

1. Use the Jira MCP server to fetch ticket details
2. Display:
   - **Summary** and **Description**
   - **Status**, **Priority**, **Assignee**
   - **Acceptance Criteria** (if present)
   - **Recent Comments** (last 5)
   - **Linked Issues** and **Sub-tasks**
3. If the ticket has sub-tasks, show their completion status
4. Highlight any blockers or dependencies
