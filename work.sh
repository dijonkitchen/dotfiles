#!/bin/bash

source "$HOME/dotfiles/python.sh"

# MySQL
export PATH="$HOMEBREW_PREFIX/opt/mysql@5.7/bin:$PATH"

# MongoDB
export PATH="$HOMEBREW_PREFIX/opt/mongodb-community@4.0/bin:$PATH"

[[ -f ~/.robinssh/bin/completion.zsh ]] && . ~/.robinssh/bin/completion.zsh
