# Claude Code Marketplace

Private plugin marketplace for Claude Code. Single source of truth for skills, hooks, agents, and MCP servers.

## Quick Start

```bash
# Clone the marketplace
git clone git@github.com:declan-moonward/claude-code-marketplace.git
cd claude-code-marketplace

# Install all plugins
./scripts/install.sh

# Or install a specific plugin
./scripts/install.sh team-standards
```

## How It Works

The install script creates symlinks from your `~/.claude/` directory to this repo. When plugins are updated, pull the latest and re-run the installer:

```bash
git pull && ./scripts/install.sh
```

## Plugins

| Plugin | Description | Status |
|--------|-------------|--------|
| **team-standards** | Code review, PR creation, ticket workflows, quality-gate hooks, reviewer agent | Stable |
| **jira-integration** | Jira ticket management and workflow automation | Stable |
| **qa-tools** | QA testing utilities | Coming soon |

## Structure

```
├── .claude-plugin/
│   └── marketplace.json          # Plugin catalogue
├── plugins/
│   ├── team-standards/           # Core dev team plugin
│   │   ├── skills/               # code-review, pr-create, ticket-workflow
│   │   ├── agents/               # reviewer agent
│   │   ├── hooks/                # lint-check, pre-commit-checks
│   │   └── .mcp.json             # GitHub, Jira, Notion, Figma MCP servers
│   ├── jira-integration/         # Jira-specific skills
│   └── qa-tools/                 # QA tools (planned)
├── scripts/
│   ├── install.sh                # Install/update plugins
│   └── uninstall.sh              # Remove plugins
└── README.md
```

## MCP Server Setup

The `team-standards` plugin includes MCP server configs for GitHub, Jira, Notion, and Figma. Set these environment variables before using:

```bash
export GITHUB_TOKEN="your-token"
export JIRA_API_TOKEN="your-token"
export JIRA_EMAIL="you@company.com"
export JIRA_URL="https://yourcompany.atlassian.net"
export NOTION_API_KEY="your-key"
export FIGMA_ACCESS_TOKEN="your-token"
```

## Uninstall

```bash
# Remove all plugins
./scripts/uninstall.sh

# Remove a specific plugin
./scripts/uninstall.sh team-standards
```

## Adding a New Plugin

1. Create a directory under `plugins/your-plugin-name/`
2. Add `.claude-plugin/plugin.json` with plugin metadata
3. Add skills, agents, hooks as needed
4. Update `.claude-plugin/marketplace.json` in the root
5. Push and notify the team
