# Path for brew
test -d /usr/local/bin && export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

# heroku autocomplete setup
HEROKU_AC_BASH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/bash_setup && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;

# Homebrew bash completion script
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
