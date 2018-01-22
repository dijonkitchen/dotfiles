# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
HIST_STAMPS="yyyy-mm-dd"
plugins=(git gitfast bundler)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Added for rbenv when switching to zsh
export PATH="$HOME/.rbenv/bin:$PATH"
# Original
# eval "$(rbenv init -)"
# Modified for reusing previous sessions's directory in iTerm2
# export SHELL="/usr/local/bin/zsh"
if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi

# For Postgres gem to work with Postgres App
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

source $ZSH/oh-my-zsh.sh
source $HOME/dotfiles/settings.sh

# From brew install zsh notes for online help
unalias run-help
autoload run-help
HELPDIR=/usr/local/share/zsh/help
