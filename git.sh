#!/bin/bash

# must be after bash completions are sourced
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

# For faster typing
alias g='git'

if [ -n "${BASH_VERSION}" ]; then
    export PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND ;}'__git_ps1 "\[\e[1m\]\w\[\e[0m\]" "\\\$ "'
    # autocomplete using alias
    __git_complete g __git_main
elif [ -n "${ZSH_VERSION}" ]; then
    precmd () { __git_ps1 "%B%~%b" "%s$ "; }
fi
