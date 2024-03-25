#!/usr/bin/env bash

# Included in personal homebrew.sh
# export PATH="/opt/homebrew/bin:$PATH"

export SSL_CERT_FILE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export REQUESTS_CA_BUNDLE="/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
export NODE_EXTRA_CA_CERTS="/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
# Included in personal javascript.sh
# export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

## Find and Trust Netskope CA ##
## Combined CA Cert Created with $(security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain /Library/Keychains/System.keychain > /tmp/nscacert_combined.pem && sudo cp /tmp/nscacert_combined.pem "/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem")
export REQUESTS_CA_BUNDLE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export NODE_EXTRA_CA_CERTS="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export AWS_CA_BUNDLE="/opt/homebrew/etc/ca-certificates/cert.pem"
# export AWS_CA_BUNDLE="/usr/local/etc/ca-certificates/cert.pem" # FYI - In some cases this will be the correct path, depending on how you installed AWS CLI
export PIP_CERT="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export HTTPLIB2_CA_CERTS="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export GAM_CA_FILE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"

export AWS_PROFILE='autoawsume-default'
alias awsume='. awsume'

export SPRING_DIRECTORY=$HOME/SpringCare
