#!/bin/bash
#
# create-baseline.sh
# Creates a complete baseline snapshot by running all capture scripts
#
# Output: Timestamped snapshot directory with all state files
# Usage: ./create-baseline.sh [snapshot_name]

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Generate snapshot directory name
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
HOSTNAME=$(hostname -s)
SNAPSHOT_NAME="${1:-$TIMESTAMP-$HOSTNAME}"
SNAPSHOT_DIR="$BASE_DIR/snapshots/$SNAPSHOT_NAME"

echo "========================================"
echo "Creating State Baseline Snapshot"
echo "========================================"
echo "Snapshot name: $SNAPSHOT_NAME"
echo "Output directory: $SNAPSHOT_DIR"
echo ""

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Create metadata file
cat > "$SNAPSHOT_DIR/metadata.json" <<EOF
{
  "snapshot_name": "$SNAPSHOT_NAME",
  "capture_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostname": "$(hostname)",
  "username": "$USER",
  "os_version": "$(sw_vers -productVersion)",
  "build_version": "$(sw_vers -buildVersion)",
  "machine_model": "$(sysctl -n hw.model)",
  "capture_scripts": []
}
EOF

# Track which scripts ran successfully
SCRIPTS_RUN=()

echo "Running capture scripts..."
echo ""

# Run login items capture
echo "[1/2] Capturing login items..."
if [[ -x "$SCRIPT_DIR/capture-login-items-state.sh" ]]; then
    if "$SCRIPT_DIR/capture-login-items-state.sh" "$SNAPSHOT_DIR"; then
        SCRIPTS_RUN+=("capture-login-items-state.sh")
        echo "  ✓ Login items captured"
    else
        echo "  ✗ Failed to capture login items"
    fi
else
    echo "  ⊘ Script not found or not executable: capture-login-items-state.sh"
fi
echo ""

# Run notification settings capture
echo "[2/2] Capturing notification settings..."
if [[ -x "$SCRIPT_DIR/capture-notification-settings-state.sh" ]]; then
    if "$SCRIPT_DIR/capture-notification-settings-state.sh" "$SNAPSHOT_DIR"; then
        SCRIPTS_RUN+=("capture-notification-settings-state.sh")
        echo "  ✓ Notification settings captured"
    else
        echo "  ✗ Failed to capture notification settings"
    fi
else
    echo "  ⊘ Script not found or not executable: capture-notification-settings-state.sh"
fi
echo ""

# Update metadata with scripts that ran
if command -v python3 &> /dev/null; then
    python3 -c "
import json
import sys

with open('$SNAPSHOT_DIR/metadata.json', 'r') as f:
    metadata = json.load(f)

metadata['capture_scripts'] = $(printf '%s\n' "${SCRIPTS_RUN[@]}" | jq -R . | jq -s .)

with open('$SNAPSHOT_DIR/metadata.json', 'w') as f:
    json.dump(metadata, f, indent=2)
" 2>/dev/null || echo "Note: Could not update metadata.json with script list"
fi

# Create snapshot summary
cat > "$SNAPSHOT_DIR/README.txt" <<EOF
State Baseline Snapshot
=======================

Snapshot Name: $SNAPSHOT_NAME
Created: $(date)
Hostname: $(hostname)
User: $USER
OS Version: $(sw_vers -productVersion) ($(sw_vers -buildVersion))

Files in this snapshot:
-----------------------
EOF

# List all files created
find "$SNAPSHOT_DIR" -type f -exec basename {} \; | sort | sed 's/^/  - /' >> "$SNAPSHOT_DIR/README.txt"

echo ""
echo "========================================"
echo "Snapshot created successfully!"
echo "========================================"
echo "Location: $SNAPSHOT_DIR"
echo ""
echo "Files created:"
find "$SNAPSHOT_DIR" -type f -exec basename {} \; | sort | sed 's/^/  - /'
echo ""
echo "To view the snapshot:"
echo "  cd $SNAPSHOT_DIR"
echo "  cat README.txt"
echo ""
echo "To compare with another snapshot:"
echo "  # (comparison scripts will be available in Phase 2)"
echo ""
