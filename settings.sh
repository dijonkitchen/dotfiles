#!/bin/bash

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

source "$HOME/dotfiles/homebrew.sh"
source "$HOME/dotfiles/git.sh"
source "$HOME/dotfiles/alias.sh"

source "$HOME/dotfiles/javascript.sh"
source "$HOME/dotfiles/ruby.sh"
source "$HOME/dotfiles/python.sh"

if [ -n "${WORKMODE}" ]; then
  source "$HOME/dotfiles/work.sh"
fi

export PAGER=less

