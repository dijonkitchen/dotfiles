#!/usr/bin/env bash
# Link agent-agnostic content (.agent/skills-source) and per-agent runtime
# configs into the locations each AI coding agent expects.
#
# Add a new agent by appending a block below. The canonical content lives in
# .agent/ and is shared; only the surface symlinks change per agent.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/.agent/skills-source/.agent/skills"

is_codespaces() { [[ "${CODESPACES:-}" == "true" ]] || [[ -d /workspaces/.codespaces ]]; }
if is_codespaces; then LN_OPTS="-sf"; else LN_OPTS="-si"; fi

link_skills_into() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "warn: $SKILLS_DIR not found; did you 'git subtree pull' the skills repo?" >&2
    return 0
  fi
  for skill in "$SKILLS_DIR"/*/; do
    [[ -d "$skill" ]] || continue
    local name
    name="$(basename "$skill")"
    ln $LN_OPTS "$skill" "$target_dir/$name"
  done
}

# --- Claude Code -----------------------------------------------------------
mkdir -p "$HOME/.claude"
ln $LN_OPTS "$SCRIPT_DIR/.claude/settings.json"        "$HOME/.claude/settings.json"
ln $LN_OPTS "$SCRIPT_DIR/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link_skills_into "$HOME/.claude/skills"

# --- Future adapters -------------------------------------------------------
# Each block is opt-in: only links when that agent's config dir already
# exists, so installs are non-destructive on machines without the tool.
#
# Cursor:  if [[ -d "$HOME/.cursor" ]]; then link_skills_into "$HOME/.cursor/rules"; fi
# Codex:   if [[ -d "$HOME/.codex"  ]]; then link_skills_into "$HOME/.codex/skills"; fi
# Aider/Copilot are per-repo, not global -- handle in project setup, not here.
