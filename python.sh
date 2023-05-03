#!/usr/bin/env bash

if command -v pyenv 1>/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

if command -v direnv 1>/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# Poetry PATH
if [ -d "$HOME/.local/bin/" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
