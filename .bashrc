#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"

# Add new items below to proper file for organization
