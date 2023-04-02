#!/bin/bash

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

if ! type brew &>/dev/null &&
    {
      [ -e "/opt/homebrew" ] ||
      [ -e "/usr/local/Homebrew" ] ||
      [ -e "/home/linuxbrew/.linuxbrew" ] &&
      [ -z "${HOMEBREW_MAIN_USER}" ]
    };
then
    echo "Existing Homebrew installation detected."
    echo "In $HOME/dotfiles/secrets.sh, set HOMEBREW_MAIN_USER=original-installer-username"
else
    if [ -n "${HOMEBREW_MAIN_USER}" ]; then
        echo "Using 'brew' as HOMEBREW_MAIN_USER: ${HOMEBREW_MAIN_USER}. Enter your password for single Homebrew use."
        alias brew='sudo -Hiu $HOMEBREW_MAIN_USER brew'
    fi

    HOMEBREW_PREFIX="$(brew --prefix)"

    # Path for brew binaries in multi-user mode
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:~/bin:$PATH"
fi
