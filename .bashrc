#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"

# After settings.sh, which puts ~/.local/bin (where mise lives) on PATH
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# Add new items below to proper file for organization
