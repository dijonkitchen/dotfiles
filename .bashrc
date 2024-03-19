#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

# Rust initialization for Ruby YJIT
. "$HOME/.cargo/env"

eval "$(~/.local/bin/mise activate bash)"

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"
