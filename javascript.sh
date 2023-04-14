#!/usr/bin/env bash

export NVM_DIR="$HOME/.nvm"

# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

if command -v nvm 1>/dev/null 2>&1; then
  # This loads nvm shell completions
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # place this after nvm initialization!
  if [ -n "${BASH_VERSION}" ]; then
    cdnvm() {
        command cd "$@" || return $?
        nvm_path=$(nvm_find_up .nvmrc | tr -d '\n')

        # If there are no .nvmrc file, use the default nvm version
        if [[ ! $nvm_path = *[^[:space:]]* ]]; then

            declare default_version;
            default_version=$(nvm version default);

            # If there is no default version, set it to `node`
            # This will use the latest version on your machine
            if [[ $default_version == "N/A" ]]; then
                nvm alias default node;
                default_version=$(nvm version default);
            fi

            # If the current version is not the default version, set it to use the default version
            if [[ $(nvm current) != "$default_version" ]]; then
                nvm use default;
            fi

        elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
            declare nvm_version
            nvm_version=$(<"$nvm_path"/.nvmrc)

            declare locally_resolved_nvm_version
            # `nvm ls` will check all locally-available versions
            # If there are multiple matching versions, take the latest one
            # Remove the `->` and `*` characters and spaces
            # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
            locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')

            # If it is not already installed, install it
            # `nvm install` will implicitly use the newly-installed version
            if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
                nvm install "$nvm_version";
            elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
                nvm use "$nvm_version";
            fi
        fi
    }

    alias cd='cdnvm'
    cdnvm "$PWD" || exit
  elif [ -n "${ZSH_VERSION}" ]; then
    autoload -U add-zsh-hook

    load-nvmrc() {
      local nvmrc_path
      nvmrc_path="$(nvm_find_nvmrc)"

      if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version
        nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

        if [ "$nvmrc_node_version" = "N/A" ]; then
          nvm install
        elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
          nvm use
        fi
      elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
      fi
    }

    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
  fi
fi
