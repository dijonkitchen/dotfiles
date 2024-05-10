#!/usr/bin/env bash

alias be="bundle exec"

# Rust initialization for Ruby YJIT
. "$HOME/.cargo/env"
export RUBY_YJIT_ENABLE=1

#if command -v rbenv 1>/dev/null 2>&1; then
#  eval "$(rbenv init -)"
#fi
