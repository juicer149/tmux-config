#!/usr/bin/env bash
#
# Bootstrap install script for tmux configuration.
#
# Responsibilities:
# - Verify tmux is installed
# - Ensure helper scripts are executable
# - Provide a canonical tmux.conf entrypoint
# - Optionally link ~/.tmux.conf to this repo
#
# This script is:
# - explicit
# - idempotent
# - safe to re-run
#

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TMUX_CONF="${ROOT_DIR}/tmux.conf"
OSC_SCRIPT="${ROOT_DIR}/osc52-copy.sh"
HOME_TMUX_CONF="${HOME}/.tmux.conf"

echo "[tmux] bootstrap install"

# -------------------------------------------------------------------
# Verify tmux exists
# -------------------------------------------------------------------

if ! command -v tmux >/dev/null 2>&1; then
  echo "[error] tmux is not installed"
  echo "        install tmux using your system package manager"
  exit 1
fi

echo "[ok] tmux found: $(command -v tmux)"

# -------------------------------------------------------------------
# Ensure OSC52 helper is executable
# -------------------------------------------------------------------

if [ -f "${OSC_SCRIPT}" ]; then
  chmod +x "${OSC_SCRIPT}"
  echo "[ok] osc52 helper executable"
else
  echo "[error] osc52-copy.sh not found"
  exit 1
fi

# -------------------------------------------------------------------
# Ensure repo-local tmux.conf exists
# -------------------------------------------------------------------

if [ ! -f "${TMUX_CONF}" ]; then
  echo "[error] tmux.conf missing in repo"
  exit 1
fi

echo "[ok] tmux.conf present in repo"

# -------------------------------------------------------------------
# Link ~/.tmux.conf (explicit but safe)
# -------------------------------------------------------------------

if [ -e "${HOME_TMUX_CONF}" ] && [ ! -L "${HOME_TMUX_CONF}" ]; then
  echo "[skip] ~/.tmux.conf already exists (not touching it)"
  echo "       you may link it manually if desired:"
  echo "       ln -s ${TMUX_CONF} ${HOME_TMUX_CONF}"
  exit 0
fi

if [ -L "${HOME_TMUX_CONF}" ]; then
  echo "[ok] ~/.tmux.conf already linked"
  exit 0
fi

ln -s "${TMUX_CONF}" "${HOME_TMUX_CONF}"
echo "[link] ~/.tmux.conf -> ${TMUX_CONF}"

echo "[done] tmux bootstrap complete"
