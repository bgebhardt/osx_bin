# State Synchronization System

A collection of scripts for capturing, comparing, and synchronizing system state across macOS machines. This system complements the [main setup scripts](../README.md) by helping you maintain consistency between multiple Macs and tracking configuration drift over time.

## Status

**Phase 1: COMPLETE** ✅ - All capture scripts implemented and tested
**Phase 2: COMPLETE** ✅ - Activity-based tier generation + subset install scripts
**Phase 3: COMPLETE** ✅ - SSH-based push + interactive remote apply

See [PLAN-activity-based-provisioning.md](PLAN-activity-based-provisioning.md) for the design.

## Quick Start

```bash
SS=~/bin/setup/state-sync/scripts

# A) Capture everything (state + GUI activity + CLI activity)
$SS/create-baseline.sh                # Runs all 11 capture-* scripts

# B) Generate GUI app tiers + filtered Brewfile subset
$SS/generate-app-tiers.sh             # → snapshots/<latest>/tiers/{tier-*.json, tiers-report.md}
$SS/generate-tier-brewfile.sh --tier essentials
                                      # → snapshots/<latest>/tiers/install/Brewfile.essentials
                                      #   (+ manual.txt, promotions.txt, post-install-*.sh if needed)

# C) Rank CLI tools by frequency (independent from GUI tiers)
$SS/generate-cli-tiers.sh             # → snapshots/<latest>/cli-tiers/{cli-tier-*.json, cli-tiers-report.md}

# D) Push to a new Mac and apply (interactive, always dry-run first)
$SS/push-to-mac.sh newmac.local --dry-run
$SS/push-to-mac.sh newmac.local --tier essentials --include configs

# E) Restore app preferences from a snapshot (e.g. for a single app)
$SS/restore-app-prefs.sh --dry-run --apps com.googlecode.iterm2
```

Default snapshot dir: `$HOME/bin/setup/state-sync/snapshots/` (override in `~/.state-sync-config`).
See [README-configuration.md](README-configuration.md) for details.

## Activity-Based Provisioning (Phase 2/3)

The provisioning flow has four layers:

1. **Capture usage** —
   - `capture-app-usage.sh` scans `/Applications`, `/Applications/Utilities`, and
     `~/Applications`. Reads `kMDItemLastUsedDate` and `kMDItemUseCount` from Spotlight,
     plus Dock pins and login items. Outputs `app-usage.json` ranked by a composite score.
   - `capture-cli-usage.sh` parses `~/.bash_history` and `~/.zsh_history`, counts command
     frequency, resolves each command to its install source (brew formula / system /
     other), and writes `cli-usage.json`. Shell builtins, project-relative paths, and
     unresolved noise (JSON fragments, etc.) are kept in separate fields for inspection.
     Use `generate-cli-tiers.sh` to rank the kept commands into top-N essentials /
     regular / rare buckets with a markdown report at `cli-tiers/cli-tiers-report.md`.

2. **Tier generation** (`generate-app-tiers.sh` + `lib-classify-app.sh`) — Splits apps into
   three exclusive tiers based on tunable thresholds:
   - **essentials**: in Dock OR login item OR (use_count ≥ 20 AND used ≤ 30d ago)
   - **regular**: used ≤ 90d ago
   - **rare**: everything else

   Each app is also tagged with `install_type` (brew/mas/other) and its cask_name or mas_id.

3. **Tier Brewfile generation** (`generate-tier-brewfile.sh`) — For a chosen tier
   (essentials / regular / all), reads the latest generated snapshot Brewfile
   (`setup/homebrew/Brewfile.<hostname>.<date>`, produced by `generate-brewfiles.py`)
   and emits a tier subset:
   - `Brewfile.<tier>` — primary install manifest (`brew bundle install --file=`)
   - `install-<tier>-manual.txt` — apps with no brew/mas line available
   - `install-<tier>-promotions.txt` — audit log of `other` → brew/mas promotions
     (matched against active *and* tombstone entries in the snapshot Brewfile)
   - `post-install-<tier>.sh` — optional, only if any tier app triggers a hook
     in the static map (claude installer, pipx-installed `llm`, etc. — things
     Brewfile can't express)
   - `summary-<tier>.txt`

   Tombstones (commented-out `# cask "foo"` entries in the snapshot Brewfile) are
   how the "promotions" feature works without re-parsing `brew-cask.sh`: the
   generator (`generate-brewfiles.py`) carries over each commented
   `# brew install foo` line from the source scripts as a tombstone with
   provenance (`[tombstone brew-cask.sh:NNN]`).

4. **SSH push + remote apply** (`push-to-mac.sh` + `apply-on-remote.sh`) — Builds a
   transfer bundle, rsyncs it to a target Mac (with `--dry-run` preview), and runs the
   apply script interactively over SSH. Each stage prompts before doing anything:
   Homebrew → `brew bundle check` preview → brew formulae → brew casks → mas →
   post-install hooks → manual install list → app configs (Karabiner, Rectangle,
   Raycast) → mac-defaults.sh → app preference plists.

   The brew/cask/mas stages all run against the same `Brewfile.<tier>` using
   `brew bundle install --no-X` filters, so each type can still be skipped
   independently.

## Purpose

The state-sync system serves several key purposes:

1. **System Auditing** - Capture snapshots of your current system configuration
2. **Configuration Drift Detection** - Compare current state against known-good baselines
3. **Machine Synchronization** - Copy configuration between machines (old Mac � new Mac)
4. **Change Tracking** - Document what has changed since initial setup
5. **Backup Validation** - Verify critical settings are preserved

## Scripts

All scripts live in `scripts/`. Tunable thresholds (tier cutoffs, etc.) are
constants at the top of each generator script.

### Capture (state → snapshot dir)

| Script | What it captures | Output file(s) |
|---|---|---|
| `capture-app-state.sh` | Installed apps: brew formulae, casks, MAS apps, `/Applications` apps with version | `app-state.json`, `app-state.txt` |
| `capture-app-usage.sh` | GUI app usage via Spotlight `kMDItemLastUsedDate` + `kMDItemUseCount`, Dock pins, login items | `app-usage.json`, `app-usage.txt` |
| `capture-cli-usage.sh` | CLI command frequency from `~/.bash_history` + `~/.zsh_history`, classified by install source | `cli-usage.json`, `cli-usage.txt` |
| `capture-system-prefs.sh` | macOS system defaults plists (Dock, Finder, Trackpad, Keyboard, …) | `system-prefs.json`, `plists/` |
| `capture-app-prefs.sh` | Per-app plist exports (Terminal, iTerm2, VS Code, Chrome, …) | `app-prefs.json`, `app-plists/*.plist` |
| `capture-dev-env.sh` | Versions of dev tools, env vars, git config (no key material) | `dev-env.json`, `dev-env.txt` |
| `capture-shell-config.sh` | Copies of `.bashrc` / `.zshrc` / `.profile` / etc. | `shell-config.json`, `dotfiles/` |
| `capture-onedrive-state.sh` | Which OneDrive dirs are currently downloaded locally | `onedrive-state.json` |
| `capture-onedrive-state-interactive.sh` | Same, with interactive prompts | `onedrive-state.json` |
| `capture-login-items-state.sh` | Login items + LaunchAgents via `osascript` + `sfltool` | `login-items.json` |
| `capture-notification-settings-state.sh` | Per-app notification settings | `notification-settings.json` |
| `capture-steam-game-state.sh` | Installed Steam games | `steam-games.json` |

### Orchestration

| Script | Purpose |
|---|---|
| `create-baseline.sh` | Runs every `capture-*` script in order, writing into a timestamped snapshot dir. Shows per-step elapsed time and a `✓`/`✗` indicator. |

### Tier generation (snapshot → ranked manifests)

| Script | Reads | Writes |
|---|---|---|
| `lib-classify-app.sh` | (sourceable) `brew list --cask` + `mas list` | Index JSON keyed by lowercase app name → `{install_type, cask_name, mas_id}` |
| `generate-app-tiers.sh` | `app-usage.json` + classification index | `tiers/tier-{essentials,regular,rare}.json`, `tiers/tiers-report.md`, `tiers/unclassified.txt`, `tiers/summary.txt` |
| `generate-cli-tiers.sh` | `cli-usage.json` | `cli-tiers/cli-tier-{essentials,regular,rare}.json`, `cli-tiers/cli-tiers-report.md`, `cli-tiers/cli-tiers-summary.txt` |

### Tier Brewfile generation (tier → Brewfile subset)

| Script | Purpose |
|---|---|
| `lib-brewfile-parse.sh` | (sourceable) Helpers for looking up cask/brew/mas/tap entries in a Brewfile. Returns `active:<line>` / `tombstone:<line>` / empty. Also exposes `find_latest_snapshot_brewfile`. |
| `generate-tier-brewfile.sh --tier <essentials\|regular\|all> [--brewfile <path>]` | For the chosen tier, reads the latest snapshot Brewfile (or one passed via `--brewfile`) and emits `Brewfile.<tier>` + `install-<tier>-manual.txt` + `install-<tier>-promotions.txt` + optional `post-install-<tier>.sh`. Promotions match against tombstone entries (commented `# cask "foo"`) too. |

### Push / apply (old Mac → new Mac over SSH)

| Script | Purpose |
|---|---|
| `push-to-mac.sh <host> [--tier ...] [--include configs,prefs,defaults\|all] [--dry-run] [--no-run]` | Builds a transfer bundle (Brewfile.tier + manual.txt + promotions.txt + optional post-install + `configs/`, captured plists, `mac-defaults.sh`), runs an `rsync --dry-run` preview, prompts to confirm, then rsyncs and optionally invokes `apply-on-remote.sh` interactively via SSH. Refreshes the snapshot Brewfile (via `generate-brewfiles.py`) before tier generation so tombstones are current. Excludes obvious secret patterns automatically. |
| `templates/apply-on-remote.sh [--dry-run] [--all-yes]` | The script shipped to and run on the target Mac. Lives under `templates/` for easier review since it's the only "code that runs elsewhere". Walks 10 stages, each opt-in: Homebrew detect/install (skips if already at `/opt/homebrew/bin/brew` or `/usr/local/bin/brew`) → `brew bundle check` preview → formulae (`brew bundle install --no-cask --no-mas`) → casks (`--no-brew --no-mas`) → mas (with sign-in check, `--no-brew --no-cask`) → `post-install-<tier>.sh` → manual install list → configs copy → `mac-defaults.sh` → plist restore. `push-to-mac.sh` copies this file into the bundle. |
| `restore-app-prefs.sh [--dry-run] [--all] [--apps DOMAIN,…] [snapshot_dir]` | Runs `defaults import` on each `.plist` in the snapshot's `app-plists/` directory. Prompts per-domain by default. |

### Not yet implemented (TODO)

These appeared in the original plan but aren't built yet:

| Script | Purpose |
|---|---|
| `compare-states.sh` | Diff two snapshot directories |
| `compare-to-baseline.sh` | Diff current state vs a named baseline |
| `drift-report.sh` | Markdown drift report |
| `sync-from-machine.sh` | Pull configs from another Mac (inverse of `push-to-mac.sh`) |
| `restore-system-prefs.sh` | Re-apply captured system defaults (currently use `setup/macOS/mac-defaults.sh` via `apply-on-remote.sh`) |
| `schedule-snapshots.sh` | launchd job for weekly/monthly snapshots |
| `list-snapshots.sh` | Tabular listing of all snapshots |

## Implementation Approach (historical plan)

> The phases below are the original design plan. Phases 1–3 are implemented;
> see [PLAN-activity-based-provisioning.md](PLAN-activity-based-provisioning.md)
> for what was actually built. Phase 4 (scheduling, drift reports) is partially
> done — `create-baseline.sh` is the convenience entry point, but launchd
> scheduling and `compare-states.sh` / `drift-report.sh` are still TODO.

### Phase 1: Foundation (State Capture)

**Goal:** Establish the ability to capture current system state reliably.

**Steps:**

1. **Create snapshot directory structure**

   ```bash
   ~/bin/setup/state-sync/
      snapshots/           # Stored snapshots
      baselines/           # Known-good baselines
      scripts/             # Executable scripts
      templates/           # Config templates
   ```

2. **Implement core capture scripts**
   - Start with `capture-app-state.sh` (leverages existing audit scripts)
   - Reuse logic from `apps-by-install-type.sh`
   - Output to structured JSON for easy parsing

3. **Build on existing tools**
   - Extend `brew-audit.sh`, `mas-audit.sh`, `brew-cask-audit.sh`
   - Use `defaults read` for plist captures
   - Leverage `diff-plist.sh` patterns

4. **Test capture accuracy**
   - Run on current machine
   - Verify all critical apps/settings captured
   - Validate JSON/output format

### Phase 2: Comparison & Diff

**Goal:** Enable comparing snapshots to detect changes.

**Steps:**

1. **Implement comparison engine**
   - JSON diff for app lists
   - plist diff for preferences
   - Text diff for config files

2. **Create reporting formats**
   - Terminal-friendly colored output
   - Markdown reports for documentation
   - Optional HTML reports with styling

3. **Define comparison modes**
   - App presence (installed vs. not installed)
   - App versions (version changes)
   - Preference values (setting changes)
   - Config content (line-by-line diffs)

4. **Build baseline system**
   - Capture "fresh install" state
   - Capture "fully configured" state
   - Allow multiple named baselines

### Phase 3: Synchronization

**Goal:** Transfer configuration between machines.

**Steps:**

1. **Implement safe copying**
   - Use rsync with exclude patterns
   - Dry-run mode by default
   - Backup before overwrite

2. **Create selective sync**
   - Config files only (safest)
   - Application prefs (requires care)
   - System prefs (requires validation)

3. **Add safety checks**
   - Verify SSH connectivity
   - Check disk space
   - Validate file permissions
   - Confirm before system changes

4. **Build restore capabilities**
   - Restore from snapshot
   - Selective restore (choose what to restore)
   - Rollback support

### Phase 4: Automation & Integration

**Goal:** Make the system easy to use regularly.

**Steps:**

1. **Create convenience commands**
   - Single command to capture everything
   - Single command to compare to baseline
   - Single command to sync from another Mac

2. **Add scheduling**
   - Optional launchd integration
   - Weekly snapshots for tracking drift
   - Notification on significant changes

3. **Integrate with main setup**
   - Add to main README workflow
   - Reference in setup scripts
   - Use during new machine setup

4. **Documentation**
   - Add usage examples
   - Document common workflows
   - Create troubleshooting guide

## Common Workflows

### Workflow 1: Provision a new Mac with only the apps I actually use

```bash
SS=~/bin/setup/state-sync/scripts

# On the OLD Mac — full capture, then generate tiers + Brewfile subset
$SS/create-baseline.sh                                # 11 capture scripts (~90s)
$SS/generate-app-tiers.sh                             # GUI app tiers + report
$SS/generate-cli-tiers.sh                             # CLI tool tiers + report
$SS/generate-tier-brewfile.sh --tier essentials       # Brewfile.essentials subset

# Review what would be transferred (no SSH side-effects yet)
open ~/bin/setup/state-sync/snapshots/<latest>/tiers/tiers-report.md
open ~/bin/setup/state-sync/snapshots/<latest>/cli-tiers/cli-tiers-report.md

# Push to the new Mac (dry-run, then real)
$SS/push-to-mac.sh newmac.local --tier essentials --include configs --dry-run
$SS/push-to-mac.sh newmac.local --tier essentials --include configs

# push-to-mac.sh will offer to run apply-on-remote.sh interactively over SSH.
# Each install stage prompts on the target Mac.
```

### Workflow 2: Inspect what's used vs what's installed

```bash
SS=~/bin/setup/state-sync/scripts
$SS/capture-app-usage.sh    # GUI usage from Spotlight + Dock + login items
$SS/capture-cli-usage.sh    # CLI usage from shell history
$SS/generate-app-tiers.sh
$SS/generate-cli-tiers.sh

# Browse the reports
ls ~/bin/setup/state-sync/snapshots/<latest>/{tiers,cli-tiers}/*.md
```

### Workflow 3: Restore individual app preferences

```bash
SS=~/bin/setup/state-sync/scripts

# From the latest snapshot, dry-run first
$SS/restore-app-prefs.sh --dry-run

# Restore only specific apps
$SS/restore-app-prefs.sh --apps com.googlecode.iterm2,com.microsoft.VSCode

# Or restore everything captured without prompting
$SS/restore-app-prefs.sh --all
```

### Workflow 4: Periodic drift check (manual until `compare-states.sh` exists)

```bash
SS=~/bin/setup/state-sync/scripts
$SS/create-baseline.sh "$(date +%Y-%m-%d)-weekly"

# Manual diff for now — compare two snapshots' app-state.json
diff <(jq -S . snapshots/old/app-state.json) \
     <(jq -S . snapshots/new/app-state.json) | less
```

## Design Principles

1. **Non-destructive by default** - Always show what will change before changing it
2. **Incremental adoption** - Each script works independently, use what you need
3. **Leverage existing tools** - Build on brew, mas, defaults, rsync
4. **Human-readable output** - JSON for machines, formatted text for humans
5. **Git-friendly** - Snapshots should be diffable in version control
6. **Security-conscious** - Never capture passwords, keys, or tokens

## Future Enhancements

- Web UI for browsing snapshots and diffs
- Integration with Time Machine for point-in-time restoration
- Cloud storage sync (iCloud, Dropbox) for snapshots
- Machine learning to detect anomalous changes
- Integration with company/team baseline configs
- Support for iOS/iPadOS device configuration

## Related Documentation

- [Main Setup Guide](../README.md) - Overall system setup process
- [App Installation](../appstore/README.md) - Application management
- [Config Management](../configs/README.md) - Configuration file handling
- [macOS Defaults](../macOS/mac-defaults.sh) - System preference automation
