#!/usr/bin/env bash
# Shared bats helpers. Sourced by individual *.bats files.

# Project root, regardless of where bats is invoked from.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT

# Build a sandbox HOME + DOTFILES_DIR that mirrors the real layout
# without touching the developer's machine. Each call gets a fresh
# tmpdir so tests are independent.
make_sandbox() {
  SANDBOX="$(mktemp -d)"
  export SANDBOX
  export HOME="$SANDBOX/home"
  mkdir -p "$HOME"

  # Copy (don't symlink) the repo into the sandbox so the script
  # under test reads from a path it owns and can append to.
  export SANDBOX_REPO="$SANDBOX/dotfiles"
  cp -R "$PROJECT_ROOT" "$SANDBOX_REPO"
}

cleanup_sandbox() {
  [[ -n "${SANDBOX:-}" && -d "$SANDBOX" ]] && rm -rf "$SANDBOX"
}
