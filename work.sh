#!/usr/bin/env bash

# shellcheck source=homebrew.sh
source "$HOME/dotfiles/homebrew.sh"
# shellcheck source=ruby.sh
source "$HOME/dotfiles/ruby.sh"

export AWS_PROFILE='autoawsume-default'
alias awsume='. awsume'

export SPRING_DIRECTORY=$HOME/SpringCare

export CERT_PATH="/Users/$(whoami)/ca_certs/zscaler-custom-ca-bundle.pem"
export CERT_DIR="/Users/$(whoami)/ca_certs/"
export SSL_CERT_FILE=${CERT_PATH}
export SSL_CERT_DIR=${CERT_DIR}
export REQUESTS_CA_BUNDLE=${CERT_PATH} # PIP,
export NODE_EXTRA_CA_CERTS=${CERT_PATH} # NPM
export AWS_CA_BUNDLE=${CERT_PATH}
export PIP_CERT=${CERT_PATH}
export HTTPLIB2_CA_CERTS=${CERT_PATH}
export SSL_CERT_FILE="${CERT_PATH}"
export GAM_CA_FILE=${CERT_PATH}
