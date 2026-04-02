#!/usr/bin/env bash
# Claude Code Marketplace - Install / Update Script
# Usage: ./scripts/install.sh [plugin-name|all]
#
# Installs plugins by symlinking skills, agents, hooks, and MCP config
# into the user's ~/.claude/ directory.

set -euo pipefail

MARKETPLACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
HOOKS_DIR="$CLAUDE_DIR/hooks"
PLUGIN_ARG="${1:-all}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[marketplace]${NC} $1"; }
warn() { echo -e "${YELLOW}[marketplace]${NC} $1"; }
info() { echo -e "${BLUE}[marketplace]${NC} $1"; }

ensure_dirs() {
  mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$HOOKS_DIR"
}

install_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  if [ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
    warn "Skipping $plugin_name - no plugin.json found"
    return
  fi

  log "Installing plugin: $plugin_name"

  # Install skills
  if [ -d "$plugin_dir/skills" ]; then
    for skill_dir in "$plugin_dir/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local target="$SKILLS_DIR/$skill_name"

      if [ -L "$target" ]; then
        rm "$target"
      fi

      if [ -e "$target" ]; then
        warn "  Skill '$skill_name' exists (not a symlink) - skipping. Remove manually to install."
        continue
      fi

      ln -s "$skill_dir" "$target"
      info "  Linked skill: $skill_name"
    done
  fi

  # Install agents
  if [ -d "$plugin_dir/agents" ]; then
    for agent_file in "$plugin_dir/agents"/*.md; do
      [ -f "$agent_file" ] || continue
      local agent_name
      agent_name="$(basename "$agent_file")"
      local target="$AGENTS_DIR/$agent_name"

      if [ -L "$target" ]; then
        rm "$target"
      fi

      if [ -e "$target" ]; then
        warn "  Agent '$agent_name' exists (not a symlink) - skipping."
        continue
      fi

      ln -s "$agent_file" "$target"
      info "  Linked agent: $agent_name"
    done
  fi

  # Install hooks
  if [ -d "$plugin_dir/hooks" ]; then
    for hook_file in "$plugin_dir/hooks"/*.sh; do
      [ -f "$hook_file" ] || continue
      local hook_name
      hook_name="$(basename "$hook_file")"
      local target="$HOOKS_DIR/$hook_name"

      if [ -L "$target" ]; then
        rm "$target"
      fi

      if [ -e "$target" ]; then
        warn "  Hook '$hook_name' exists (not a symlink) - skipping."
        continue
      fi

      ln -s "$hook_file" "$target"
      info "  Linked hook: $hook_name"
    done
  fi

  # Install MCP config (merge into project .mcp.json if it exists)
  if [ -f "$plugin_dir/.mcp.json" ]; then
    info "  MCP config available at: $plugin_dir/.mcp.json"
    info "  To use, copy or merge into your project's .mcp.json"
  fi

  log "Plugin '$plugin_name' installed successfully"
  echo ""
}

main() {
  echo ""
  log "Claude Code Marketplace Installer"
  echo "=================================="
  echo ""

  ensure_dirs

  if [ "$PLUGIN_ARG" = "all" ]; then
    for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
      [ -d "$plugin_dir" ] || continue
      install_plugin "$plugin_dir"
    done
  else
    local target_dir="$MARKETPLACE_DIR/plugins/$PLUGIN_ARG"
    if [ ! -d "$target_dir" ]; then
      warn "Plugin '$PLUGIN_ARG' not found in marketplace"
      echo ""
      info "Available plugins:"
      for plugin_dir in "$MARKETPLACE_DIR/plugins"/*/; do
        echo "  - $(basename "$plugin_dir")"
      done
      exit 1
    fi
    install_plugin "$target_dir"
  fi

  log "Installation complete!"
  echo ""
  info "To update plugins later, run: ./scripts/install.sh"
  info "Symlinks point to this repo - pull updates with: git pull && ./scripts/install.sh"
}

main
