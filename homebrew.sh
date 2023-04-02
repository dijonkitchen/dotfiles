#!/bin/bash

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

if ! type brew &>/dev/null &&
    {
      [ -e "/opt/homebrew" ] || # ARM
      [ -e "/usr/local/Homebrew" ] || # x86
      [ -e "/home/linuxbrew/.linuxbrew" ] && # Linux
      [ -z "${HOMEBREW_MAIN_USER}" ]
    };
then
    echo "Existing Homebrew installation detected."
    echo "In $HOME/dotfiles/secrets.sh, set HOMEBREW_MAIN_USER=original-installer-username"
else
    if [ -n "${HOMEBREW_MAIN_USER}" ]; then
        echo "Existing Homebrew with HOMEBREW_MAIN_USER: ${HOMEBREW_MAIN_USER}."
        echo "Enter your current user password when requested for 'brew' use."

        alias brew='sudo -Hiu $HOMEBREW_MAIN_USER brew'
    fi

    # Uncomment your version

    # ARM
    HOMEBREW_PREFIX="/opt/homebrew"

    # x86
    # HOMEBREW_PREFIX="/usr/local/Homebrew"

    # Linuxbrew
    # HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"


    # Path for brew binaries in multi-user mode
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:~/bin:$PATH"
fi
