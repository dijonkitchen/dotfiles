#!/bin/bash

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit

if [ -n "${HOMEBREW_MAIN_USER}" ]; then
    # FIXME: ignores security check for non-main homebrew user environment
    # https://zsh.sourceforge.io/Doc/Release/Completion-System.html##Use-of-compinit
    compinit -u
    # run to show possible security issues since security check is ignored
    compaudit
else
    # normal flow
    compinit
fi
# End of lines added by compinstall

source "$HOME/dotfiles/settings.sh"

