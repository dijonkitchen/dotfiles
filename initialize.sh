#!/usr/bin/env bash
set -eu

is_macos()       { [[ "${OSTYPE:-}" == "darwin"* ]]; }
is_codespaces()  { [[ "${CODESPACES:-}" == "true" ]] || [[ -d /workspaces/.codespaces ]]; }

# Resolve where the dotfiles repo lives in this environment.
# - Codespaces mounts user dotfiles at /workspaces/.codespaces/.persistedshare/dotfiles
# - macOS / Linux: clone (or already cloned) at $HOME/dotfiles
if is_codespaces; then
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
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! is_codespaces && [[ ! -d "$DOTFILES_DIR" ]]; then
  git clone https://github.com/dijonkitchen/dotfiles/ "$DOTFILES_DIR"
fi

if is_macos; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Shell + git config (Codespaces bash/zsh files exist; append our aliases)
if is_codespaces; then
  echo 'alias ls="ls -la --color=auto"' >> ~/.bashrc
  echo 'alias g="git"'                   >> ~/.bashrc
  echo 'alias be="bundle exec"'          >> ~/.bashrc
  echo 'alias ls="ls -la --color=auto"' >> ~/.zshrc
  echo 'alias g="git"'                   >> ~/.zshrc
  echo 'alias be="bundle exec"'          >> ~/.zshrc
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

# Reload shells (only meaningful when run interactively).
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" || true
[[ -f "$HOME/.zshrc"  ]] && source "$HOME/.zshrc"  || true
