#!/usr/bin/env bash

export PAGER=less

source "$HOME/dotfiles/git.sh"
source "$HOME/dotfiles/alias.sh"

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

source "$HOME/dotfiles/javascript.sh"

source "$HOME/dotfiles/homebrew.sh"

# Dependent on homebrew
source "$HOME/dotfiles/ruby.sh"
source "$HOME/dotfiles/python.sh"

if [ -n "${WORKMODE}" ]; then
  source "$HOME/dotfiles/work.sh"
fi
