#!/usr/bin/env bash

# uv emits shell-specific completion scripts. Asking for `zsh` and eval'ing
# under bash injects zsh-only builtins (`autoload`, `compdef`) which bash
# rejects. Pick the script that matches the actual interpreter.
if command -v uv &> /dev/null; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(uv generate-shell-completion bash)"
    eval "$(uvx --generate-shell-completion bash)"
  fi
fi
