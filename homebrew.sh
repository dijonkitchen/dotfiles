#!/usr/bin/env bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# $SHELL is the login shell (zsh on macOS by default) even when this
# file is sourced from bash, so use $ZSH_VERSION to detect the actual
# interpreter. `autoload` is a zsh builtin.
if [ -n "${ZSH_VERSION:-}" ]; then
  # For shell completions
  autoload -Uz compinit
  compinit
fi

