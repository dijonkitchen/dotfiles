#!/usr/bin/env bash

# Poetry PATH
if [ -d "$HOME/.local/bin/" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
