#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

eval "$(~/.local/bin/mise activate bash)"

# shellcheck source=settings.sh
source "$HOME/dotfiles/settings.sh"

# Add new items below to proper file for organization
