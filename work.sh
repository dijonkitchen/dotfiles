#!/usr/bin/env bash

[[ -f ~/.robinssh/bin/completion.zsh ]] && . ~/.robinssh/bin/completion.zsh

# https://reactnative.dev/docs/environment-setup
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
