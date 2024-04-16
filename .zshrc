#!/usr/bin/env zsh

# Uncomment for profiling start of run commands. Run `zprof` to see the results
# zmodload zsh/zprof

# Rust initialization for Ruby YJIT
. "$HOME/.cargo/env"

eval "$(~/.local/bin/mise activate zsh)"

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"
