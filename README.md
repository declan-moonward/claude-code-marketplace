# Claude Code Marketplace

Private plugin marketplace for Claude Code. Single source of truth for team skills, hooks, agents, and MCP servers.

Push an update to this repo, devs run one command to update.

---

## Setup (First Time)

### 1. Clone and install

```bash
git clone https://github.com/declan-moonward/claude-code-marketplace.git ~/.claude-marketplace && ~/.claude-marketplace/scripts/install.sh
```

This will:
- Clone this repo to `~/.claude-marketplace/`
- Copy all plugin files (skills, agents, hooks, MCP config) into `~/.claude/`
- Add a `claude-marketplace` alias to your shell

### 2. Reload your shell

```bash
source ~/.zshrc    # or source ~/.bashrc
```

### 3. Authenticate MCP servers

Open a Claude Code session and run:

```
/mcp
```

This launches a browser-based OAuth flow for each service (GitHub, Atlassian, Notion, Figma). You authenticate once per service — tokens refresh automatically after that.

### 4. Verify

In a Claude Code session, try invoking a skill:

```
/code-review
/pr-create
/ticket-workflow TICKET-123
```

---

## Updating

To pull the latest plugin updates:

```bash
claude-marketplace
```

That's it. The command pulls the latest changes and re-copies all plugin files.

To update a specific plugin only:

```bash
claude-marketplace team-standards
```

---

## What's Included

### Plugins

| Plugin | What it does | Status |
|--------|-------------|--------|
| **team-standards** | Code review, PR creation, ticket workflows, reviewer agent, lint/secret hooks | Stable |
| **jira-integration** | Jira ticket lookup and workflow automation | Stable |
| **qa-tools** | QA testing utilities | Planned |

### Skills (things you invoke)

| Skill | Command | Description |
|-------|---------|-------------|
| Code Review | `/code-review` | Multi-aspect review of current branch changes |
| PR Create | `/pr-create [TICKET-123]` | Create a well-structured PR with summary and test plan |
| Ticket Workflow | `/ticket-workflow TICKET-123` | Start work on a ticket — creates branch, sets up context |
| Jira Ticket | `/jira-ticket TICKET-123` | Fetch and display Jira ticket details |

### Hooks (things that run automatically)

| Hook | Trigger | What it does |
|------|---------|-------------|
| `lint-check.sh` | After file edit | Runs linter on edited files (ESLint, Ruff, golangci-lint) |
| `pre-commit-checks.sh` | Before commit | Blocks commits containing secrets or .env files |

### Agents (specialist subagents)

| Agent | Description |
|-------|-------------|
| `reviewer` | Multi-aspect code reviewer (security, performance, style, correctness) |

### MCP Servers (OAuth)

| Service | What it enables |
|---------|----------------|
| GitHub | Repo access, PR management, issue tracking |
| Atlassian | Jira tickets, Confluence docs |
| Notion | Page and database access |
| Figma | Design file inspection |

---

## Uninstalling

Remove all plugins but keep the repo:

```bash
~/.claude-marketplace/scripts/uninstall.sh
```

Full removal (plugins + repo clone + shell alias):

```bash
~/.claude-marketplace/scripts/uninstall.sh --full
```

---

## For Marketplace Maintainers

### Adding or updating a plugin

1. Make your changes under `plugins/your-plugin-name/`
2. If it's a new plugin, add an entry to `.claude-plugin/marketplace.json`
3. Commit and push to `main`
4. Notify devs to run `claude-marketplace` to update

### Plugin structure

```
plugins/your-plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── skills/
│   └── your-skill/
│       └── SKILL.md         # Skill definition
├── agents/
│   └── your-agent.md        # Agent definition
├── hooks/
│   └── your-hook.sh         # Hook script
└── .mcp.json                # MCP server config (optional)
```

---

## Repo Structure

```
├── .claude-plugin/
│   └── marketplace.json              # Plugin catalogue
├── plugins/
│   ├── team-standards/               # Core dev team plugin
│   │   ├── skills/                   # code-review, pr-create, ticket-workflow
│   │   ├── agents/                   # reviewer agent
│   │   ├── hooks/                    # lint-check, pre-commit-checks
│   │   └── .mcp.json                 # OAuth MCP servers
│   ├── jira-integration/             # Jira-specific skills
│   └── qa-tools/                     # QA tools (planned)
├── scripts/
│   ├── install.sh                    # Install / update (the one command)
│   └── uninstall.sh                  # Remove plugins
└── README.md
```
