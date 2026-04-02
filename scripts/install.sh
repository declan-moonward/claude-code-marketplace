#!/usr/bin/env bash
# Claude Code Marketplace - Install / Update
#
# First run:  Clones the repo to ~/.claude-marketplace/ and copies plugins into ~/.claude/
# Updates:    Pulls latest changes and re-copies plugins
#
# Usage:
#   ./scripts/install.sh                  # Install/update all plugins
#   ./scripts/install.sh team-standards   # Install/update a specific plugin
#   claude-marketplace update             # After first install, use the alias

set -euo pipefail

MARKETPLACE_DIR="$HOME/.claude-marketplace"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
HOOKS_DIR="$CLAUDE_DIR/hooks"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[marketplace]${NC} $1"; }
warn() { echo -e "${YELLOW}[marketplace]${NC} $1"; }
info() { echo -e "${BLUE}[marketplace]${NC} $1"; }

# ── Clone or pull ────────────────────────────────────────────────────────────

ensure_repo() {
  if [ -d "$MARKETPLACE_DIR/.git" ]; then
    log "Pulling latest marketplace updates..."
    git -C "$MARKETPLACE_DIR" pull --ff-only 2>&1 | sed 's/^/  /'
  else
    echo ""
    warn "Marketplace repo not found at $MARKETPLACE_DIR"
    warn "Clone it first:"
    echo ""
    echo "  git clone git@github.com:declan-moonward/claude-code-marketplace.git ~/.claude-marketplace"
    echo ""
    exit 1
  fi
  echo ""
}

# ── Install plugins ─────────────────────────────────────────────────────────

ensure_dirs() {
  mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$HOOKS_DIR"
}

install_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  if [ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
    warn "Skipping $plugin_name — no plugin.json found"
    return
  fi

  log "Installing plugin: $plugin_name"

  # Copy skills
  if [ -d "$plugin_dir/skills" ]; then
    for skill_dir in "$plugin_dir/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local target="$SKILLS_DIR/$skill_name"
      rm -rf "$target"
      cp -R "$skill_dir" "$target"
      info "  Installed skill: $skill_name"
    done
  fi

  # Copy agents
  if [ -d "$plugin_dir/agents" ]; then
    for agent_file in "$plugin_dir/agents"/*.md; do
      [ -f "$agent_file" ] || continue
      local agent_name
      agent_name="$(basename "$agent_file")"
      cp -f "$agent_file" "$AGENTS_DIR/$agent_name"
      info "  Installed agent: $agent_name"
    done
  fi

  # Copy hooks
  if [ -d "$plugin_dir/hooks" ]; then
    for hook_file in "$plugin_dir/hooks"/*.sh; do
      [ -f "$hook_file" ] || continue
      local hook_name
      hook_name="$(basename "$hook_file")"
      cp -f "$hook_file" "$HOOKS_DIR/$hook_name"
      chmod +x "$HOOKS_DIR/$hook_name"
      info "  Installed hook: $hook_name"
    done
  fi

  # Copy MCP config
  if [ -f "$plugin_dir/.mcp.json" ]; then
    cp -f "$plugin_dir/.mcp.json" "$CLAUDE_DIR/.mcp.json"
    info "  Installed MCP config"
  fi

  log "Plugin '$plugin_name' installed"
  echo ""
}

# ── Shell alias ──────────────────────────────────────────────────────────────

install_alias() {
  local shell_rc=""
  if [ -f "$HOME/.zshrc" ]; then
    shell_rc="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    shell_rc="$HOME/.bashrc"
  fi

  if [ -z "$shell_rc" ]; then
    return
  fi

  local alias_line="alias claude-marketplace=\"\$HOME/.claude-marketplace/scripts/install.sh\""

  if ! grep -qF "claude-marketplace" "$shell_rc" 2>/dev/null; then
    echo "" >> "$shell_rc"
    echo "# Claude Code Marketplace" >> "$shell_rc"
    echo "$alias_line" >> "$shell_rc"
    info "Added 'claude-marketplace' alias to $(basename "$shell_rc")"
    info "Run 'source $shell_rc' or open a new terminal to use it"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  local plugin_arg="${1:-all}"

  echo ""
  log "Claude Code Marketplace"
  echo "========================"
  echo ""

  ensure_repo
  ensure_dirs

  if [ "$plugin_arg" = "all" ]; then
    for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
      [ -d "$plugin_dir" ] || continue
      install_plugin "$plugin_dir"
    done
  else
    local target_dir="$MARKETPLACE_DIR/plugins/$plugin_arg"
    if [ ! -d "$target_dir" ]; then
      warn "Plugin '$plugin_arg' not found in marketplace"
      echo ""
      info "Available plugins:"
      for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
        echo "  - $(basename "$plugin_dir")"
      done
      exit 1
    fi
    install_plugin "$target_dir"
  fi

  install_alias

  echo ""
  log "All done!"
  info "To update later, run: claude-marketplace"
  info "To authenticate MCP servers, run /mcp in Claude Code"
}

main "$@"
