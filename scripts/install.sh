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
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

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
    echo "  git clone https://github.com/declan-moonward/claude-code-marketplace.git ~/.claude-marketplace"
    echo ""
    exit 1
  fi
  echo ""
}

# ── Install plugins ─────────────────────────────────────────────────────────

ensure_dirs() {
  mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$HOOKS_DIR"
}

check_deps() {
  if ! command -v jq &>/dev/null; then
    warn "jq is required but not installed."
    warn "Install it: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
  fi
}

# ── Hooks wiring ────────────────────────────────────────────────────────────

install_hooks_config() {
  local plugin_dir="$1"
  local plugin_json="$plugin_dir/.claude-plugin/plugin.json"

  # Check if plugin has hooks array
  local hooks_count
  hooks_count=$(jq -r '.hooks | if type == "array" then length else 0 end' "$plugin_json" 2>/dev/null || echo "0")
  [ "$hooks_count" -gt 0 ] || return 0

  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  # Initialize settings.json if it doesn't exist
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Build hook entries from plugin.json and merge into settings.json
  local i=0
  while [ "$i" -lt "$hooks_count" ]; do
    local event matcher command if_filter
    event=$(jq -r ".hooks[$i].event" "$plugin_json")
    matcher=$(jq -r ".hooks[$i].matcher" "$plugin_json")
    command=$(jq -r ".hooks[$i].command" "$plugin_json")
    if_filter=$(jq -r ".hooks[$i].if // empty" "$plugin_json")

    # Resolve command to installed path
    local hook_script="$HOOKS_DIR/$(basename "$command")"

    # Build the hook handler object
    local hook_handler
    if [ -n "$if_filter" ]; then
      hook_handler=$(jq -n --arg cmd "$hook_script" --arg if_val "$if_filter" \
        '{"type": "command", "command": $cmd, "if": $if_val}')
    else
      hook_handler=$(jq -n --arg cmd "$hook_script" \
        '{"type": "command", "command": $cmd}')
    fi

    # Build the matcher group with a marketplace tag for tracking
    local matcher_group
    matcher_group=$(jq -n --arg m "$matcher" --arg src "marketplace:$plugin_name" \
      --argjson handler "$hook_handler" \
      '{"matcher": $m, "_source": $src, "hooks": [$handler]}')

    # Merge into settings.json: add to the event array, replacing any existing entry from same source
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg event "$event" --arg src "marketplace:$plugin_name" \
       --argjson new_group "$matcher_group" \
      '
      .hooks //= {} |
      .hooks[$event] //= [] |
      # Remove existing entries from same marketplace source with same matcher
      .hooks[$event] = [.hooks[$event][] | select(._source != $src or .matcher != $new_group.matcher)] |
      # Add the new entry
      .hooks[$event] += [$new_group]
      ' "$SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$SETTINGS_FILE"

    i=$((i + 1))
  done

  info "  Configured hooks in settings.json"
}

# ── MCP config merge ────────────────────────────────────────────────────────

merge_mcp_config() {
  local plugin_mcp="$1"

  if [ ! -f "$CLAUDE_DIR/.mcp.json" ]; then
    cp -f "$plugin_mcp" "$CLAUDE_DIR/.mcp.json"
  else
    # Deep merge: plugin values override existing for same keys, existing keys preserved
    local tmp_file
    tmp_file=$(mktemp)
    jq -s '.[0] * .[1]' "$CLAUDE_DIR/.mcp.json" "$plugin_mcp" > "$tmp_file" \
      && mv "$tmp_file" "$CLAUDE_DIR/.mcp.json"
  fi
}

# ── Install plugins ─────────────────────────────────────────────────────────

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

  # Merge MCP config
  if [ -f "$plugin_dir/.mcp.json" ]; then
    merge_mcp_config "$plugin_dir/.mcp.json"
    info "  Installed MCP config"
  fi

  # Wire hooks into settings.json
  install_hooks_config "$plugin_dir"

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

  check_deps
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

  # Install global CLAUDE.md
  if [ -f "$MARKETPLACE_DIR/CLAUDE.md" ]; then
    cp -f "$MARKETPLACE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    info "Installed global CLAUDE.md (team coding standards)"
  fi

  install_alias

  echo ""
  log "All done!"
  info "To update later, run: claude-marketplace"
  info "To authenticate MCP servers, run /mcp in Claude Code"
}

main "$@"
