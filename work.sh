#!/bin/bash

source "$HOME/dotfiles/python.sh"

# MySQL
export PATH="/opt/homebrew/opt/mysql@5.7/bin:/usr/local/opt/mysql@5.7/bin:$PATH"

# MongoDB
export PATH="/opt/homebrew/opt/mongodb-community@4.0/bin:/usr/local/opt/mongodb-community@4.0/bin:$PATH"

[[ -f ~/.robinssh/bin/completion.zsh ]] && . ~/.robinssh/bin/completion.zsh
