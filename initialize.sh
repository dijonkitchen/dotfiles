#!/usr/bin/env bash

is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }

if is_macos; then
  # Install Apple Developer Tools (git, etc.)
  xcode-select --install

  # Change shell to default to bash
  # chsh -s "$(which bash)"

  # Install [Homebrew](https://brew.sh/)
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Clone this repository into your `$HOME` directory:
cd "$HOME" || exit
git clone https://github.com/dijonkitchen/dotfiles/

if is_macos; then
  # To install all the brew packages from the
  # [Brewfile](https://github.com/Homebrew/homebrew-bundle),
  cd "$HOME"/dotfiles || exit
  brew bundle --file=Brewfile
fi

# In your `$HOME` directory,
# symbolic link these files:
cd "$HOME" || exit
ln -si ./dotfiles/.bashrc .
ln -si ./dotfiles/.bash_profile .
ln -si ./dotfiles/.zshrc .

# Optionally link `.gitconfig`
# or use your own credentials.
ln -si ./dotfiles/.gitconfig .

# Claude Code settings
mkdir -p "$HOME/.claude"
ln -si "$HOME/dotfiles/.claude/settings.json" "$HOME/.claude/settings.json"
ln -si "$HOME/dotfiles/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# mise for language version management (skip if not installed)
if command -v mise >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/mise"
  cd "$HOME/.config/mise" || exit
  ln -si ../../dotfiles/config.toml .
  mise install
fi

source "$HOME/.bashrc"
source "$HOME/.zshrc"
