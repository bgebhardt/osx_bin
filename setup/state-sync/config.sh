#!/bin/bash
#
# config.sh
# Configuration file for state-sync system
#
# This file defines default locations and settings for the state synchronization system.
# You can override these settings by:
#   1. Setting environment variables (highest priority)
#   2. Creating ~/.state-sync-config with your settings
#   3. Using this default config file (lowest priority)

# Default snapshot directory
# Override with STATE_SYNC_SNAPSHOT_DIR environment variable
DEFAULT_SNAPSHOT_DIR="$HOME/bin/setup/state-sync/snapshots"

# Default baseline directory
# Override with STATE_SYNC_BASELINE_DIR environment variable
DEFAULT_BASELINE_DIR="$HOME/bin/setup/state-sync/baselines"

# Load user-specific config if it exists
USER_CONFIG="$HOME/.state-sync-config"
if [[ -f "$USER_CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$USER_CONFIG"
fi

# Get snapshot directory (priority: env var > user config > default)
get_snapshot_dir() {
    if [[ -n "${STATE_SYNC_SNAPSHOT_DIR:-}" ]]; then
        echo "$STATE_SYNC_SNAPSHOT_DIR"
    elif [[ -n "${SNAPSHOT_DIR:-}" ]]; then
        echo "$SNAPSHOT_DIR"
    else
        echo "$DEFAULT_SNAPSHOT_DIR"
    fi
}

# Get baseline directory (priority: env var > user config > default)
get_baseline_dir() {
    if [[ -n "${STATE_SYNC_BASELINE_DIR:-}" ]]; then
        echo "$STATE_SYNC_BASELINE_DIR"
    elif [[ -n "${BASELINE_DIR:-}" ]]; then
        echo "$BASELINE_DIR"
    else
        echo "$DEFAULT_BASELINE_DIR"
    fi
}

# Export functions for use in other scripts
export -f get_snapshot_dir
export -f get_baseline_dir
