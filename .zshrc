# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

source $HOME/dotfiles/settings.sh

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/jonchen/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

