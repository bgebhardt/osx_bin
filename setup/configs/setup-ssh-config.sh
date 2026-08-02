#!/bin/bash
#
# setup-ssh-config.sh
# Installs the base ~/.ssh/config from this repo's template, and restores the
# private, host-specific ~/.ssh/config.local from 1Password.
#
# The base config (ssh_config in this directory) is safe to version in a
# public repo: it only wires up the 1Password SSH agent. Anything host- or
# hostname-specific (like auth overrides for a particular server) belongs in
# ~/.ssh/config.local, which this script pulls from a 1Password item instead
# of git.
#
# Usage: ./setup-ssh-config.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_DIR="$HOME/.ssh"
OP_ITEM="SSH Config Local"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# --- Base config (from repo) ---
if [[ -f "$SSH_DIR/config" ]]; then
    echo "~/.ssh/config already exists, not overwriting."
    echo "  Compare with: diff $SCRIPT_DIR/ssh_config $SSH_DIR/config"
else
    cp "$SCRIPT_DIR/ssh_config" "$SSH_DIR/config"
    chmod 600 "$SSH_DIR/config"
    echo "Installed ~/.ssh/config"
fi

# --- Private per-host overrides (from 1Password) ---
if [[ -f "$SSH_DIR/config.local" ]]; then
    echo "~/.ssh/config.local already exists, leaving it alone."
    exit 0
fi

if ! command -v op >/dev/null 2>&1; then
    echo "op (1Password CLI) not found. Install it, then run:"
    echo "  op read \"op://Private/$OP_ITEM/notesPlain\" > ~/.ssh/config.local"
    echo "Or paste the contents in by hand."
    touch "$SSH_DIR/config.local"
    chmod 600 "$SSH_DIR/config.local"
    exit 0
fi

if op read "op://Private/$OP_ITEM/notesPlain" > "$SSH_DIR/config.local" 2>/dev/null; then
    chmod 600 "$SSH_DIR/config.local"
    echo "Restored ~/.ssh/config.local from 1Password item '$OP_ITEM'."
else
    echo "Could not read 1Password item '$OP_ITEM' (not signed in, or item doesn't exist yet)."
    echo "  Sign in with: eval \$(op signin)"
    echo "  Then re-run this script, or manually run:"
    echo "    op read \"op://Private/$OP_ITEM/notesPlain\" > ~/.ssh/config.local"
    touch "$SSH_DIR/config.local"
    chmod 600 "$SSH_DIR/config.local"
fi
