#!/usr/bin/env bash

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

# For faster typing
alias g='git'

# assumes `xcode-select --install` already done on macOS
source "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"

if [ -n "${BASH_VERSION}" ]; then
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND ;}'__git_ps1 "\[\e[1m\]\w\[\e[0m\]" "\\\$ "'

    # autocomplete using alias
    source "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
    __git_complete g __git_main
elif [ -n "${ZSH_VERSION}" ]; then
    precmd () { __git_ps1 "%B%~%b" "%s$ "; }
fi
