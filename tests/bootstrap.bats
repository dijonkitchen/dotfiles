#!/usr/bin/env bats

load test_helper

setup() {
  make_sandbox
  # Run bootstrap as if we were in Codespaces on Linux. This exercises
  # the path that ships in the most ephemeral environment (where
  # idempotency and silent overwrites matter most), and avoids the
  # macOS branch's xcode-select / brew calls that we can't run in CI.
  export CODESPACES=true
  export OSTYPE=linux-gnu
  export DOTFILES_DIR="$SANDBOX_REPO"
}

teardown() {
  cleanup_sandbox
}

run_bootstrap() {
  # Run bootstrap inside the sandbox. We deliberately do NOT 'source'
  # it because it ends with `source ~/.bashrc`, which would pollute
  # the bats process. Forking a subshell isolates state.
  bash "$SANDBOX_REPO/bootstrap.sh"
}

@test "Codespaces branch appends alias source line to ~/.bashrc and ~/.zshrc" {
  run_bootstrap

  expected="source \"$SANDBOX_REPO/alias.sh\""
  grep -qxF "$expected" "$HOME/.bashrc"
  grep -qxF "$expected" "$HOME/.zshrc"
}

@test "Codespaces branch is idempotent: alias source line is not duplicated on re-run" {
  run_bootstrap
  run_bootstrap

  expected="source \"$SANDBOX_REPO/alias.sh\""
  bash_count=$(grep -cxF "$expected" "$HOME/.bashrc")
  zsh_count=$(grep -cxF "$expected" "$HOME/.zshrc")

  [ "$bash_count" -eq 1 ]
  [ "$zsh_count" -eq 1 ]
}

@test "links .gitconfig into \$HOME" {
  run_bootstrap

  [ -L "$HOME/.gitconfig" ]
  [ "$(readlink "$HOME/.gitconfig")" = "$SANDBOX_REPO/.gitconfig" ]
}

@test "delegates to link-agents.sh (Claude Code symlinks present)" {
  run_bootstrap

  [ -L "$HOME/.claude/settings.json" ]
  [ -L "$HOME/.claude/CLAUDE.md" ]
}

@test "honors pre-set DOTFILES_DIR override" {
  # Already exported in setup. Just assert it took effect by checking
  # that the appended source line points at the sandbox path, not at
  # the hardcoded /workspaces/... Codespaces default.
  run_bootstrap

  ! grep -q '/workspaces/.codespaces' "$HOME/.bashrc"
  grep -q "$SANDBOX_REPO/alias.sh" "$HOME/.bashrc"
}
