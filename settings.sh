#!/usr/bin/env bash

export PAGER=less

# shellcheck source=git.sh
source "$HOME/dotfiles/git.sh"
# shellcheck source=alias.sh
source "$HOME/dotfiles/alias.sh"

if [ -e "$HOME/dotfiles/config.sh" ];
then
  # shellcheck source=config.sh
  source "$HOME/dotfiles/config.sh"
fi

# shellcheck source=homebrew.sh
source "$HOME/dotfiles/homebrew.sh"

# shellcheck source=ruby.sh
source "$HOME/dotfiles/ruby.sh"
# shellcheck source=python.sh
source "$HOME/dotfiles/python.sh"

export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
