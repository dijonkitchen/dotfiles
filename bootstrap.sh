#!/usr/bin/env bash
# Codespaces auto-runs this on container creation.
# Manual setups should call ./initialize.sh directly.
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/initialize.sh"
