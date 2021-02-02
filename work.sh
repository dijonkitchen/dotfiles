#!/bin/bash

source "$HOME/dotfiles/python.sh"

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
