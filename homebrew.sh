#!/bin/bash

# TODO: potentially check for existing homebrew installation and warn user to add main user
if [ -n "${HOMEBREW_MAIN_USER}" ]; then
    echo "Using 'brew' as HOMEBREW_MAIN_USER: ${HOMEBREW_MAIN_USER}. Enter your password for single Homebrew use."
    alias brew='sudo -Hiu $HOMEBREW_MAIN_USER brew'
fi

HOMEBREW_PREFIX="$(brew --prefix)"

# Path for brew binaries in multi-user mode
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:~/bin:$PATH"


if type brew &>/dev/null; then
    if [ -n "${BASH_VERSION}" ]; then
        # Heroku autocomplete setup
        HEROKU_AC_BASH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/bash_setup && test -f "$HEROKU_AC_BASH_SETUP_PATH" && source "$HEROKU_AC_BASH_SETUP_PATH";

        # Homebrew bash completion script
        if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
            source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
        else
            for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
                [[ -r "$COMPLETION" ]] && source "$COMPLETION"
            done
        fi
    elif [ -n "${ZSH_VERSION}" ]; then
        # Homebrew zsh completion script
        # must be done before compinit
        FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    fi
fi
