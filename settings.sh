source /usr/local/etc/bash_completion.d/git-completion.bash
source /usr/local/etc/bash_completion.d/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

export PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND ;}'__git_ps1 "\[\e[1m\]\w\[\e[0m\]" "\\\$ "'
# export PS1='\w$(__git_ps1 " (%s)")\$ '

alias cd-='cd -'
alias e='emacs'
alias e.='e .'
alias ls='ls -GAlph'

# For faster typing and autocomplete with alias
alias g='git'
__git_complete g __git_main
