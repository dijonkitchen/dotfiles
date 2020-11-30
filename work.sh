#!/bin/bash

source "$HOME/dotfiles/python.sh"

if [ -e "$HOME/dotfiles/secrets.sh" ];
then
  source "$HOME/dotfiles/secrets.sh"
fi

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

alias db-migrate='node node_modules/db-migrate/bin/db-migrate --config config/database.json -m server/_shared/database/migrations'

migrateMongo() {
    migrate_mongo_command="node node_modules/migrate-mongo/bin/migrate-mongo"
    if [[ $1 == "status" || $1 == "up" || $1 == "down" || $1 == "create" ]]; then
        $migrate_mongo_command $@ --file config/migrate-mongo-config.js
    else
        $migrate_mongo_command $@
    fi
}
