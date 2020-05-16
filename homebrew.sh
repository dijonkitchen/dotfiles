# Path for brew

test -d /usr/local/bin && export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

if [ -n "${BASH_VERSION}" ]; then
    # heroku autocomplete setup
    HEROKU_AC_BASH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/bash_setup && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;

    # Homebrew bash completion script
    if type brew &>/dev/null; then
        HOMEBREW_PREFIX="$(brew --prefix)"
        if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
            source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
        else
            for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
                [[ -r "$COMPLETION" ]] && source "$COMPLETION"
            done
        fi
    fi
elif [ -n "${ZSH_VERSION}" ]; then
    if type brew &>/dev/null; then
        # must be done before compinit
        FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    fi
fi

export PATH="/usr/local/opt/ruby/bin:$PATH"