#!/bin/bash

# MySQL
export PATH="$HOMEBREW_PREFIX/opt/mysql@5.7/bin:$PATH"

# MongoDB
export PATH="$HOMEBREW_PREFIX/opt/mongodb-community@4.0/bin:$PATH"

[[ -f ~/.robinssh/bin/completion.zsh ]] && . ~/.robinssh/bin/completion.zsh

# https://reactnative.dev/docs/environment-setup
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
