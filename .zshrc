#!/usr/bin/env zsh

# Uncomment for profiling start of run commands. Run `zprof` to see the results
# zmodload zsh/zprof

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"

# Add new items below to proper files for organization
