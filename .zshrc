#!/usr/bin/env zsh

# Uncomment for profiling start of run commands. Run `zprof` to see the results
# zmodload zsh/zprof

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"

# After settings.sh, which puts ~/.local/bin (where mise lives) on PATH
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Add new items below to proper files for organization
