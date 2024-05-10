#!/usr/bin/env bash

# shellcheck source=homebrew.sh
source "$HOME/dotfiles/homebrew.sh"
# shellcheck source=ruby.sh
source "$HOME/dotfiles/ruby.sh"

export AWS_PROFILE='autoawsume-default'
alias awsume='. awsume'

export SPRING_DIRECTORY=$HOME/SpringCare
