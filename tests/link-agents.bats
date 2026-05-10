#!/usr/bin/env bats

load test_helper

setup() {
  make_sandbox
  # Force the non-interactive code path so ln won't prompt under bats.
  export CODESPACES=true
}

teardown() {
  cleanup_sandbox
}

@test "links Claude Code config files into ~/.claude/" {
  "$SANDBOX_REPO/link-agents.sh"

  [ -L "$HOME/.claude/settings.json" ]
  [ -L "$HOME/.claude/statusline-command.sh" ]
  [ -L "$HOME/.claude/CLAUDE.md" ]

  # Each link should resolve to a real file inside the repo copy.
  [ "$(readlink "$HOME/.claude/settings.json")" = "$SANDBOX_REPO/.claude/settings.json" ]
  [ "$(readlink "$HOME/.claude/CLAUDE.md")"      = "$SANDBOX_REPO/.claude/CLAUDE.md" ]
}

@test "links every skill folder under .agent/skills/" {
  # Add a synthetic skill alongside whatever real skills exist.
  mkdir -p "$SANDBOX_REPO/.agent/skills/synthetic-skill"
  echo "stub" > "$SANDBOX_REPO/.agent/skills/synthetic-skill/SKILL.md"

  "$SANDBOX_REPO/link-agents.sh"

  [ -L "$HOME/.claude/skills/synthetic-skill" ]
  [ -f "$HOME/.claude/skills/synthetic-skill/SKILL.md" ]
}

@test "skips non-directory entries under .agent/skills/" {
  # README.md / LICENSE come along with the subtree; they must not
  # produce phantom symlinks like ~/.claude/skills/README.md.
  "$SANDBOX_REPO/link-agents.sh"

  [ ! -e "$HOME/.claude/skills/README.md" ]
  [ ! -e "$HOME/.claude/skills/LICENSE" ]
}

@test "is idempotent: second run leaves identical state" {
  "$SANDBOX_REPO/link-agents.sh"
  first=$(find "$HOME/.claude" -printf '%P %l\n' | sort)

  "$SANDBOX_REPO/link-agents.sh"
  second=$(find "$HOME/.claude" -printf '%P %l\n' | sort)

  [ "$first" = "$second" ]
}
