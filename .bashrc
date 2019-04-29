# Path for brew
test -d /usr/local/bin && export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

if type brew &>/dev/null; then
  for COMPLETION in $(brew --prefix)/etc/bash_completion.d/*
  do
    [[ -f $COMPLETION ]] && source "$COMPLETION"
  done
  if [[ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]];
  then
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  fi
fi

source /usr/local/etc/bash_completion.d/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

export PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND ;}'__git_ps1 "\[\e[1m\]\w\[\e[0m\]" "\\\$ "'
# export PS1='\w$(__git_ps1 " (%s)")\$ '

# For faster typing and autocomplete with alias
alias g='git'
__git_complete g __git_main

alias cd-='cd -'
alias e='emacsclient -cna ""'
alias e.='e .'
alias ls='ls -GAlph'

# heroku autocomplete setup
HEROKU_AC_BASH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/bash_setup && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;

export SPACEMACSDIR="~/dotfiles/.spacemacs.d/"

export JAVA_TOOL_OPTIONS="-Dapple.awt.UIElement=true"

export PAGER=less
