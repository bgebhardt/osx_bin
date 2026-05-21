# Plan: Activity-Based Mac Provisioning (extends `state-sync`)

## Context

There is a rich set of install scripts in `~/bin/setup/` (brew formulae, casks, MAS, manual), plus a `state-sync/` system whose **Phase 1 captures are done but Phases 2–4 (diff, sync, restore) were never finished and "never worked well"**. The current "essentials" tier (`brew-cask-minimum.sh`) is hand-curated.

Goals:
1. Mine the last 90 days of actual app usage to identify what is really used, not just what's installed.
2. Generate a **tiered subset** of the existing install scripts (essentials / regular / rare).
3. From the old Mac, **push over SSH** to a new Mac and apply: the install subset plus captured settings.

This plan extends `state-sync/` to deliver the missing Phase 2–4 capability, anchored on activity data rather than pure inventory diffs. Where existing Phase 1 captures are sound they're reused; where they "never worked well" we treat them as candidates for repair, not preservation.

## Architecture

Four layers, all under `setup/state-sync/scripts/`:

```
┌──────────────────────────────────────────────────────────┐
│ Layer 1: USAGE CAPTURE  (new)                            │
│   capture-app-usage.sh  →  app-usage.json                │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│ Layer 2: TIER GENERATION  (new)                          │
│   generate-app-tiers.sh →  tier-{essentials,regular,rare}│
│                            .json                         │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│ Layer 3: SUBSET INSTALL SCRIPT GENERATION  (new)         │
│   generate-install-scripts.sh                            │
│      → install-<tier>-brew.sh                            │
│      → install-<tier>-brew-cask.sh                       │
│      → install-<tier>-mas.sh                             │
│      → install-<tier>-manual.txt                         │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│ Layer 4: SSH PUSH + REMOTE APPLY  (new — fills Phase 3)  │
│   push-to-mac.sh <host> [--tier essentials]              │
│      → rsync bundle (scripts + configs/ + snapshot)      │
│      → ssh run apply-on-remote.sh                        │
│   apply-on-remote.sh (runs on target)                    │
│      → installs apps, restores configs, runs defaults    │
└──────────────────────────────────────────────────────────┘
```

## Layer 1 — Usage capture

**New file:** `setup/state-sync/scripts/capture-app-usage.sh`

Uses Spotlight metadata (no sudo, no entitlements):

```bash
mdfind -0 'kMDItemContentType == "com.apple.application-bundle"' | \
  xargs -0 -I{} mdls -name kMDItemLastUsedDate -name kMDItemUseCount \
        -name kMDItemDisplayName "{}"
```

Combines four signals into one ranked JSON record per app:

| Signal | Source | Weight |
|---|---|---|
| `last_used_date` | `mdls kMDItemLastUsedDate` | recency score |
| `use_count` | `mdls kMDItemUseCount` | frequency score |
| `in_dock` | `defaults read com.apple.dock persistent-apps` | +pin bonus |
| `is_login_item` | `osascript -e 'tell application "System Events" to get the name of every login item'` (existing logic in `capture-login-items-state.sh`) | +pin bonus |

Output: `<snapshot-dir>/app-usage.json`, one entry per app in `/Applications`:
```json
{ "name": "Obsidian", "path": "/Applications/Obsidian.app",
  "last_used": "2026-05-19T08:42:11Z", "use_count": 248,
  "in_dock": true, "is_login_item": false, "score": 982 }
```

Add a call to this script from `create-baseline.sh` so usage is part of every snapshot.

## Layer 2 — Tier generation

**New file:** `setup/state-sync/scripts/generate-app-tiers.sh`

Reads `app-usage.json` and emits three tier manifests:

- **`tier-essentials.json`** — in Dock OR login item OR (`use_count ≥ 20` AND used in last 30d). The minimum to be functional.
- **`tier-regular.json`** — used at least once in last 90d.
- **`tier-rare.json`** — everything else (older or no Spotlight data).

Thresholds live at the top of the script as variables so they can be tuned. Each manifest lists the app name plus install type, classified by **reusing the associative-array logic from `setup/appstore/apps-by-install-type.sh:50-108`**. Refactor that classification into a sourceable helper (`lib-classify-app.sh`) so both the existing script and the new tier generator share it.

Output:
```
<snapshot-dir>/tiers/
  tier-essentials.json   # ~20-40 apps
  tier-regular.json      # ~50-100 apps
  tier-rare.json         # everything else
  unclassified.txt       # apps Spotlight saw but classifier couldn't categorize
```

## Layer 3 — Subset install scripts

**New file:** `setup/state-sync/scripts/generate-install-scripts.sh`

Given a tier manifest, generates install scripts that mirror existing patterns:

| Generated file | Source it filters | Pattern reused |
|---|---|---|
| `install-<tier>-brew.sh` | `setup/homebrew/brew.sh` | `brew install <name>` lines |
| `install-<tier>-brew-cask.sh` | `setup/homebrew/brew-cask.sh` | `brew install --cask <name>` lines |
| `install-<tier>-mas.sh` | `setup/appstore/mas.sh` | `mas install <id>` lines |
| `install-<tier>-manual.txt` | `setup/appstore/install-other-apps.sh` | URLs + names (human-applied) |

Implementation: for each tier app, grep the matching line out of the source install script and append to the generated file. Apps the classifier marked "other" but appear in tier-essentials go into `install-<tier>-manual.txt` with their `/Applications` path.

Side benefit: produces a clean **diff against `brew-cask-minimum.sh`** so the hand-curated essentials can be compared to the data-driven ones.

## Layer 4 — SSH push + remote apply

**New file:** `setup/state-sync/scripts/push-to-mac.sh`

Usage:
```
push-to-mac.sh <host> [--tier essentials|regular|all] [--dry-run] \
               [--include configs|prefs|defaults|all]
```

Steps:
1. Run capture-app-usage → generate-app-tiers → generate-install-scripts locally so the bundle is fresh.
2. Build a transfer bundle in `/tmp/state-sync-bundle-<timestamp>/` containing:
   - The generated `install-<tier>-*.sh` scripts
   - `setup/configs/` (Karabiner, Raycast, Rectangle JSON, FastScripts CSV)
   - Captured plist exports for restored apps (from snapshot)
   - `apply-on-remote.sh`
   - A `MANIFEST.txt` summarizing what's in the bundle
3. `rsync -avz --dry-run` first (default), show changes, prompt to confirm.
4. `rsync` to `<host>:~/state-sync-incoming/`.
5. `ssh <host> "bash ~/state-sync-incoming/apply-on-remote.sh"`.

**New file:** `setup/state-sync/scripts/apply-on-remote.sh`

Runs on the target Mac. Interactive by default with a checklist:
1. Ensure Homebrew installed (prompt only if missing).
2. Run `install-<tier>-brew.sh`.
3. Run `install-<tier>-brew-cask.sh`.
4. `mas` installs **prompt for App Store sign-in first**, then run `install-<tier>-mas.sh`.
5. Print `install-<tier>-manual.txt` for human action.
6. If `--include configs`: copy `configs/karabiner/`, RectangleConfig.json, Raycast .rayconfig into appropriate destinations (logic exists in `setup/configs/copy-configs.sh` — reuse).
7. If `--include defaults`: run `setup/macOS/mac-defaults.sh`.
8. If `--include prefs`: restore captured plists (new `restore-app-prefs.sh`).

**Safety rules baked in:**
- Default mode is interactive with confirm-before-each-step.
- `--dry-run` everywhere shows what would happen.
- Bundle excludes anything matching `*token*`, `*secret*`, `*.key`, `ssh_*`, `.env*`, `*-keychain*`.
- `apply-on-remote.sh` never runs `sudo` without prompting.

## Phase 1 health check (do this first)

Since the existing capture scripts "never worked well," before extending them:

1. Run `setup/state-sync/scripts/create-baseline.sh` and observe failures.
2. For each capture script that errors, fix in place — don't rewrite. Likely issues:
   - `capture-onedrive-state.sh.bak` left behind suggests an aborted rewrite — investigate which version is canonical.
   - `capture-app-state.sh` may need `apps-by-install-type.sh` available on PATH or sourced — verify.
   - Snapshot dir defaults to OneDrive path per `README-state-sync.md:23` but `config.sh:14` defaults to local `~/bin/setup/state-sync/snapshots` — reconcile.
3. Only after a clean baseline run is achievable, add `capture-app-usage.sh` to the orchestrator.

## Critical files to create or modify

**New:**
- `setup/state-sync/scripts/capture-app-usage.sh`
- `setup/state-sync/scripts/generate-app-tiers.sh`
- `setup/state-sync/scripts/generate-install-scripts.sh`
- `setup/state-sync/scripts/push-to-mac.sh`
- `setup/state-sync/scripts/apply-on-remote.sh`
- `setup/state-sync/scripts/restore-app-prefs.sh`
- `setup/state-sync/scripts/lib-classify-app.sh` (refactored from `appstore/apps-by-install-type.sh`)

**Modified:**
- `setup/state-sync/scripts/create-baseline.sh` — add usage capture step.
- `setup/appstore/apps-by-install-type.sh` — source the new `lib-classify-app.sh` instead of duplicating logic.
- `setup/state-sync/README-state-sync.md` — update Phase 2/3 status, document push-to-mac workflow.
- `setup/state-sync/config.sh` — reconcile snapshot dir default with README claim.

**Reused as-is:**
- `setup/configs/copy-configs.sh` — config restore on target.
- `setup/macOS/mac-defaults.sh` — system defaults on target.
- `setup/state-sync/scripts/capture-login-items-state.sh` — login-item detection logic.

## Verification

After build:

1. **Layer 1:** Run `capture-app-usage.sh` locally. Spot-check 5 heavily-used apps (Obsidian, VS Code, 1Password, etc.) — they should score high. Spot-check 5 rarely-used — they should score low or be absent.
2. **Layer 2:** Run `generate-app-tiers.sh`. Read `tier-essentials.json` — does the list match gut feel? Compare against hand-curated `brew-cask-minimum.sh`.
3. **Layer 3:** Run `generate-install-scripts.sh --tier essentials`. Read each generated script. Each line should also exist in the source script (`brew-cask.sh` etc.).
4. **Layer 4 dry-run:** `push-to-mac.sh <test-host> --tier essentials --dry-run` — review the rsync plan and bundle contents (`ls /tmp/state-sync-bundle-*/`). Verify no secrets included.
5. **Layer 4 real:** push to a spare Mac (or VM). Run `apply-on-remote.sh` interactively, accept only the brew step first, confirm install, then iterate.
6. **Phase 1 repair sanity:** before any of the above, `create-baseline.sh` should complete without errors on the current Mac.

## Open trade-offs

- **Spotlight blind spots:** apps that auto-launch (background helpers) won't accumulate `kMDItemUseCount`. The Dock/login-items signal compensates partially. Acceptable for v1.
- **Mac App Store sign-in:** `mas` cannot install if the user isn't signed into the App Store; `apply-on-remote.sh` handles this by prompting, not auto-failing.
- **`brew-cask-minimum.sh` overlap:** the generated essentials tier may duplicate or contradict it. v1 keeps both; once trust is established the hand-curated file can be retired.
