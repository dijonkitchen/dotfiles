#!/bin/bash

alias ls='ls -FlaG'

if [ -n "${ZSH_VERSION}" ]; then
    # For actual `help` pages, similar to bash:
    # https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Accessing-On_002dLine-Help
    unalias run-help 2>/dev/null
    autoload run-help
    HELPDIR=$(brew --prefix)/share/zsh/help
    alias help=run-help
fi
