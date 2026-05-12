#!/usr/bin/env bash
# Claude Code SessionStart hook.
# Installs deps that `make check` needs (bats, shellcheck, jq) so the
# agent can run tests and linters from the start of the session. Only
# runs on Claude Code on the web; local machines manage their own deps
# via dotfiles bootstrap.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Run the install in the background so the session can start while apt
# works. 5 min cap matches the apt + index fetch worst case.
echo '{"async": true, "asyncTimeout": 300000}'

# `make test-deps` runs apt-get update, which can fail on the web image
# due to unrelated third-party PPAs. Install directly, restricting
# update to Ubuntu's own sources so a broken PPA does not break us.
need=()
for bin in bats shellcheck jq; do
  command -v "$bin" >/dev/null 2>&1 || need+=("$bin")
done

if [ ${#need[@]} -eq 0 ]; then
  exit 0
fi

sudo apt-get update \
  -o Dir::Etc::sourcelist="sources.list.d/ubuntu.sources" \
  -o Dir::Etc::sourceparts="-" \
  -o APT::Get::List-Cleanup="0"
sudo apt-get install -y "${need[@]}"
