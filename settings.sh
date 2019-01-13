source /usr/local/etc/bash_completion.d/git-completion.bash
source /usr/local/etc/bash_completion.d/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\w$(__git_ps1 " (%s)")\$ '

alias cd-='cd -'
alias e='emacs'
alias e.='e .'
alias ls='ls -GAlph'
alias g='git'
