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

# Load configuration
CONFIG_FILE="$BASE_DIR/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# Get snapshot base directory from config
SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$BASE_DIR/snapshots")

# Generate snapshot directory name
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
HOSTNAME=$(hostname -s)
SNAPSHOT_NAME="${1:-$TIMESTAMP-$HOSTNAME}"
SNAPSHOT_DIR="$SNAPSHOT_BASE/$SNAPSHOT_NAME"

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

# Define all capture scripts in order
CAPTURE_SCRIPTS=(
    "capture-app-state.sh:Application state (Homebrew, MAS, Apps)"
    "capture-system-prefs.sh:System preferences"
    "capture-app-prefs.sh:Application preferences"
    "capture-dev-env.sh:Development environment"
    "capture-shell-config.sh:Shell configuration"
    "capture-onedrive-state.sh:OneDrive sync state"
    "capture-login-items-state.sh:Login items"
    "capture-notification-settings-state.sh:Notification settings"
    "capture-steam-game-state.sh:Steam games"
)

script_num=1
total_scripts=${#CAPTURE_SCRIPTS[@]}

for script_entry in "${CAPTURE_SCRIPTS[@]}"; do
    IFS=':' read -r script_name description <<< "$script_entry"

    echo "[$script_num/$total_scripts] Capturing $description..."
    if [[ -x "$SCRIPT_DIR/$script_name" ]]; then
        if "$SCRIPT_DIR/$script_name" "$SNAPSHOT_DIR" 2>&1 | grep -q "captured successfully"; then
            SCRIPTS_RUN+=("$script_name")
            echo "  ✓ $description captured"
        else
            echo "  ✗ Failed to capture $description"
        fi
    else
        echo "  ⊘ Script not found or not executable: $script_name"
    fi
    echo ""
    ((script_num++))
done

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
