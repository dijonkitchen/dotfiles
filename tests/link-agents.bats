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

  # Each link should resolve to a real file inside the repo copy. The
  # user-scope settings come from settings.global.json, NOT the dotfiles
  # project settings.json (which carries the repo-only bootstrap hook).
  [ "$(readlink "$HOME/.claude/settings.json")" = "$SANDBOX_REPO/.claude/settings.global.json" ]
  [ "$(readlink "$HOME/.claude/CLAUDE.md")"      = "$SANDBOX_REPO/.claude/CLAUDE.md" ]
}

@test "global settings carry no project-relative hook; project settings do" {
  # The user-scope file must not reference \$CLAUDE_PROJECT_DIR, or its
  # hooks would fire (and error) in every project. The project file is
  # where the SessionStart bootstrap hook belongs.
  ! grep -q 'CLAUDE_PROJECT_DIR' "$PROJECT_ROOT/.claude/settings.global.json"
  grep -q 'session-start.sh' "$PROJECT_ROOT/.claude/settings.json"
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

@test "Claude Code on the web runs non-interactively (CLAUDE_CODE_REMOTE)" {
  # Drop the Codespaces fingerprint set in setup() so the Claude Code web
  # branch is the only thing keeping us out of interactive `ln -i` mode.
  unset CODESPACES
  export CLAUDE_CODE_REMOTE=true

  # Pre-create a conflicting target. Interactive ln would block on stdin
  # and hang the test; force mode overwrites without prompting.
  mkdir -p "$HOME/.claude"
  echo "stale" > "$HOME/.claude/CLAUDE.md"

  run "$SANDBOX_REPO/link-agents.sh" </dev/null
  [ "$status" -eq 0 ]
  [ -L "$HOME/.claude/CLAUDE.md" ]
  [ "$(readlink "$HOME/.claude/CLAUDE.md")" = "$SANDBOX_REPO/.claude/CLAUDE.md" ]
}
