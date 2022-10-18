#!/bin/bash

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

# Added to ensure Homebrew is installed
source $HOME/dotfiles/homebrew.sh

autoload -Uz compinit
compinit -u
# End of lines added by compinstall

source "$HOME/dotfiles/settings.sh"

