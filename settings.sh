#!/usr/bin/env bash

export PAGER=less

# shellcheck source=git.sh
source "$HOME/dotfiles/git.sh"
# shellcheck source=alias.sh
source "$HOME/dotfiles/alias.sh"

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  # shellcheck source=secrets.sh
  source "$HOME/dotfiles/secrets.sh"
fi

# shellcheck source=javascript.sh
source "$HOME/dotfiles/javascript.sh"

# shellcheck source=homebrew.sh
source "$HOME/dotfiles/homebrew.sh"

# Dependent on homebrew
# shellcheck source=ruby.sh
source "$HOME/dotfiles/ruby.sh"
# shellcheck source=python.sh
source "$HOME/dotfiles/python.sh"

if [ -n "${WORKMODE}" ]; then
  # shellcheck source=work.sh
  source "$HOME/dotfiles/work.sh"
fi

export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
