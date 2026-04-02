#!/usr/bin/env bash
# Claude Code Marketplace - Uninstall
#
# Removes all marketplace-installed files from ~/.claude/ and the local repo clone.
#
# Usage:
#   ./scripts/uninstall.sh                  # Remove all plugins
#   ./scripts/uninstall.sh team-standards   # Remove a specific plugin
#   ./scripts/uninstall.sh --full           # Remove plugins + repo clone + alias

set -euo pipefail

MARKETPLACE_DIR="$HOME/.claude-marketplace"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
PLUGIN_ARG="${1:-all}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[marketplace]${NC} $1"; }
warn() { echo -e "${YELLOW}[marketplace]${NC} $1"; }

uninstall_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  log "Uninstalling plugin: $plugin_name"

  # Remove skills
  if [ -d "$plugin_dir/skills" ]; then
    for skill_dir in "$plugin_dir/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local target="$CLAUDE_DIR/skills/$skill_name"
      if [ -d "$target" ]; then
        rm -rf "$target"
        log "  Removed skill: $skill_name"
      fi
    done
  fi

  # Remove agents
  if [ -d "$plugin_dir/agents" ]; then
    for agent_file in "$plugin_dir/agents"/*.md; do
      [ -f "$agent_file" ] || continue
      local agent_name
      agent_name="$(basename "$agent_file")"
      local target="$CLAUDE_DIR/agents/$agent_name"
      if [ -f "$target" ]; then
        rm -f "$target"
        log "  Removed agent: $agent_name"
      fi
    done
  fi

  # Remove hooks
  if [ -d "$plugin_dir/hooks" ]; then
    for hook_file in "$plugin_dir/hooks"/*.sh; do
      [ -f "$hook_file" ] || continue
      local hook_name
      hook_name="$(basename "$hook_file")"
      local target="$CLAUDE_DIR/hooks/$hook_name"
      if [ -f "$target" ]; then
        rm -f "$target"
        log "  Removed hook: $hook_name"
      fi
    done
  fi

  # Remove hooks from settings.json
  if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
    local source_tag="marketplace:$plugin_name"
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg src "$source_tag" '
      if .hooks then
        .hooks |= with_entries(
          .value |= [.[] | select(._source != $src)] |
          select(.value | length > 0)
        )
      else . end
    ' "$SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$SETTINGS_FILE"
    log "  Removed hooks from settings.json"
  fi

  # Remove marketplace MCP servers from .mcp.json
  if [ -f "$CLAUDE_DIR/.mcp.json" ] && [ -f "$plugin_dir/.mcp.json" ] && command -v jq &>/dev/null; then
    local mcp_keys
    mcp_keys=$(jq -r '.mcpServers // {} | keys[]' "$plugin_dir/.mcp.json" 2>/dev/null || true)
    if [ -n "$mcp_keys" ]; then
      local tmp_file
      tmp_file=$(mktemp)
      local del_args=""
      for key in $mcp_keys; do
        del_args="$del_args | del(.mcpServers.\"$key\")"
      done
      jq "${del_args# | }" "$CLAUDE_DIR/.mcp.json" > "$tmp_file" && mv "$tmp_file" "$CLAUDE_DIR/.mcp.json"
      log "  Removed MCP servers from .mcp.json"
    fi
  fi

  log "Plugin '$plugin_name' uninstalled"
}

remove_alias() {
  for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc_file" ] && grep -qF "claude-marketplace" "$rc_file"; then
      sed -i '' '/# Claude Code Marketplace/d;/claude-marketplace/d' "$rc_file"
      log "Removed alias from $(basename "$rc_file")"
    fi
  done
}

main() {
  echo ""
  log "Claude Code Marketplace Uninstaller"
  echo ""

  if [ "$PLUGIN_ARG" = "--full" ]; then
    # Remove all plugins first
    for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
      [ -d "$plugin_dir" ] || continue
      uninstall_plugin "$plugin_dir"
    done
    # Remove all marketplace hooks from settings.json
    if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
      local tmp_file
      tmp_file=$(mktemp)
      jq '
        if .hooks then
          .hooks |= with_entries(
            .value |= [.[] | select(._source == null or (._source | startswith("marketplace:") | not))] |
            select(.value | length > 0)
          )
        else . end
      ' "$SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$SETTINGS_FILE"
      log "Removed marketplace hooks from settings.json"
    fi
    # Remove MCP config if it was installed by marketplace
    if [ -f "$CLAUDE_DIR/.mcp.json" ]; then
      rm -f "$CLAUDE_DIR/.mcp.json"
      log "Removed MCP config"
    fi
    # Remove repo clone
    if [ -d "$MARKETPLACE_DIR" ]; then
      rm -rf "$MARKETPLACE_DIR"
      log "Removed marketplace repo from ~/.claude-marketplace/"
    fi
    # Remove alias
    remove_alias
  elif [ "$PLUGIN_ARG" = "all" ]; then
    for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
      [ -d "$plugin_dir" ] || continue
      uninstall_plugin "$plugin_dir"
    done
  else
    local target_dir="$MARKETPLACE_DIR/plugins/$PLUGIN_ARG"
    if [ ! -d "$target_dir" ]; then
      warn "Plugin '$PLUGIN_ARG' not found"
      exit 1
    fi
    uninstall_plugin "$target_dir"
  fi

  echo ""
  log "Uninstall complete!"
}

main
