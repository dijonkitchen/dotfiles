#!/usr/bin/env bash

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ "$(basename "$SHELL")" = "zsh" ]; then
  # For shell completions
  autoload -Uz compinit
  compinit
fi

