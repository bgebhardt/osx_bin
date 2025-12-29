# State Sync Configuration Guide

The state-sync system supports configurable snapshot and baseline locations, making it easy to store your snapshots in cloud storage like OneDrive, iCloud Drive, or Dropbox.

## Configuration Priority

Settings are loaded in this order (highest priority first):

1. **Environment Variables** - `STATE_SYNC_SNAPSHOT_DIR` and `STATE_SYNC_BASELINE_DIR`
2. **User Config File** - `~/.state-sync-config`
3. **Default Config** - `~/bin/setup/state-sync/config.sh`

## Quick Setup

### Option 1: User Config File (Recommended)

Copy the template and customize:

```bash
cp ~/bin/setup/state-sync/templates/state-sync-config.template ~/.state-sync-config
# Edit ~/.state-sync-config with your preferred locations
```

Your current configuration in `~/.state-sync-config`:
```bash
SNAPSHOT_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/snapshots"
BASELINE_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/baselines"
```

### Option 2: Environment Variables

Set environment variables (temporary):

```bash
export STATE_SYNC_SNAPSHOT_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/snapshots"
export STATE_SYNC_BASELINE_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/baselines"
```

Or add to your shell profile for persistence:

```bash
# Add to ~/.zshrc or ~/.bashrc
export STATE_SYNC_SNAPSHOT_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/snapshots"
export STATE_SYNC_BASELINE_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/baselines"
```

## Example Configurations

### OneDrive (Personal)
```bash
SNAPSHOT_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/snapshots"
BASELINE_DIR="$HOME/Library/CloudStorage/OneDrive-Personal/1 Common Info/baselines"
```

### OneDrive (Work/School)
```bash
SNAPSHOT_DIR="$HOME/Library/CloudStorage/OneDrive-Microsoft/snapshots"
BASELINE_DIR="$HOME/Library/CloudStorage/OneDrive-Microsoft/baselines"
```

### iCloud Drive
```bash
SNAPSHOT_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/state-sync/snapshots"
BASELINE_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/state-sync/baselines"
```

### Dropbox
```bash
SNAPSHOT_DIR="$HOME/Dropbox/state-sync/snapshots"
BASELINE_DIR="$HOME/Dropbox/state-sync/baselines"
```

### Local (Default)
```bash
SNAPSHOT_DIR="$HOME/bin/setup/state-sync/snapshots"
BASELINE_DIR="$HOME/bin/setup/state-sync/baselines"
```

## Verifying Configuration

To see where snapshots will be saved:

```bash
# Source the config
source ~/bin/setup/state-sync/config.sh

# Check the directories
get_snapshot_dir
get_baseline_dir
```

Or simply run a test snapshot:

```bash
~/bin/setup/state-sync/scripts/create-baseline.sh test
```

The script will print the output directory it's using.

## Benefits of Cloud Storage

Storing snapshots in cloud storage provides:

1. **Automatic Backup** - Your state snapshots are backed up automatically
2. **Cross-Machine Sync** - Access snapshots from multiple Macs
3. **Version History** - Cloud providers often keep file version history
4. **Machine Migration** - Easy to transfer state when setting up a new Mac

## Notes

- Directory paths with spaces are supported (properly quoted in scripts)
- The directories will be created automatically if they don't exist
- Individual scripts can still use custom output directories by passing a path argument
