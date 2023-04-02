#!/bin/bash

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

# For faster typing
alias g='git'

# assumes `xcode-select --install` already done on macOS
source "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"

precmd () { __git_ps1 "%B%~%b" "%s$ "; }
