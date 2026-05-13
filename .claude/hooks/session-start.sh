#!/usr/bin/env bash
# Claude Code SessionStart hook.
# On Claude Code on the web (where the user's local ~/.claude/ is not
# available), materialize this repo's .claude/ globals into ~/.claude/
# via link-agents.sh, then install the deps that `make check` needs
# (bats, shellcheck, jq) so the agent can run tests and linters from
# the start of the session. Local machines manage both via bootstrap.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Run in the background so the session can start while apt works. 5 min
# cap matches the apt + index fetch worst case.
echo '{"async": true, "asyncTimeout": 300000}'

# Symlink the dotfiles' .claude/ (statusline, CLAUDE.md, skills, the
# settings.json with this very hook) into ~/.claude/ so they apply at
# the user scope, not just the project scope. Idempotent.
"$CLAUDE_PROJECT_DIR/link-agents.sh"

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
