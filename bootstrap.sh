#!/usr/bin/env bash
set -eu

is_macos()       { [[ "${OSTYPE:-}" == "darwin"* ]]; }
is_codespaces()  { [[ "${CODESPACES:-}" == "true" ]] || [[ -d /workspaces/.codespaces ]]; }

# Resolve where the dotfiles repo lives in this environment.
# - Caller may pre-set DOTFILES_DIR (used by tests).
# - Codespaces mounts user dotfiles at /workspaces/.codespaces/.persistedshare/dotfiles
# - macOS / Linux: clone (or already cloned) at $HOME/dotfiles
if [[ -n "${DOTFILES_DIR:-}" ]]; then
  :
elif is_codespaces; then
  DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"
else
  DOTFILES_DIR="$HOME/dotfiles"
fi

# In Codespaces we need silent overwrites; locally prompt before clobbering.
if is_codespaces; then
  LN_OPTS="-sf"
else
  LN_OPTS="-si"
fi

if is_macos; then
  xcode-select --install || true
  if ! command -v brew >/dev/null 2>&1; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

if ! is_codespaces && [[ ! -d "$DOTFILES_DIR" ]]; then
  git clone https://github.com/dijonkitchen/dotfiles/ "$DOTFILES_DIR"
fi

if is_macos; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Shell + git config. Codespaces ships its own .bashrc/.zshrc that we
# don't want to clobber, so we append a single source line pointing at
# our canonical alias file. Locally we symlink the full rc files.
if is_codespaces; then
  source_line="source \"$DOTFILES_DIR/alias.sh\""
  grep -qxF "$source_line" ~/.bashrc 2>/dev/null || echo "$source_line" >> ~/.bashrc
  grep -qxF "$source_line" ~/.zshrc  2>/dev/null || echo "$source_line" >> ~/.zshrc
else
  ln $LN_OPTS "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
  ln $LN_OPTS "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
  ln $LN_OPTS "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
fi

ln $LN_OPTS "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Link agent-agnostic skills + per-agent runtime configs.
"$DOTFILES_DIR/link-agents.sh"

# mise for language version management (skip if not installed)
if command -v mise >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/mise"
  ln $LN_OPTS "$DOTFILES_DIR/config.toml" "$HOME/.config/mise/config.toml"
  mise install
fi
