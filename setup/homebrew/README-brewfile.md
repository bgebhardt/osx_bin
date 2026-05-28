# Brewfiles — declarative manifest for `brew bundle`

This directory contains both the original imperative shell scripts (`brew.sh`, `brew-cask.sh`, `brew-cask-minimum.sh`, `brew-cask-work.sh`, `brew-work.sh`) **and** a set of declarative Brewfiles for use with `brew bundle`. They coexist — neither replaces the other.

The Brewfiles are organized as a **cascade of role/persona overlays**. Each layer is additive and contains only items not already in the layers below it.

| File | Role | Layer position |
| --- | --- | --- |
| `Brewfile` | **Master** — single union of "everything I want installed somewhere across all my Macs." Hand-curated. | Stand-alone |
| `Brewfile.minimum` | **Hand-curated.** Fresh-machine essentials (terminal, browsers, 1Password, VS Code, GitHub Desktop, the few things you'd want on minute 1). | Base |
| `Brewfile.homeserver` | **Hand-curated.** CLI tools, dev tools, AI/LLM CLIs, networking & system utilities. Usable on a headless box. | Adds to `minimum` |
| `Brewfile.desktop` | **Hand-curated.** GUI Mac apps for day-to-day personal use (most casks, MAS apps, VS Code extensions). | Adds to `minimum + homeserver` |
| `Brewfile.work` | **Hand-curated.** Work-machine-only overlay (auth/MDM tools, work-licensed apps). Currently a placeholder + journal. | Adds to `minimum + homeserver + desktop` |
| `Brewfile.games` | **Hand-curated.** Steam, Epic, Battle.net, game launchers. Optional overlay on any machine. | Stand-alone overlay |
| `Brewfile.<host>.<YYYY-MM-DD>` | Per-machine, per-day snapshot of what's *actually* installed. **Only file the generator writes.** Diff against the master to see drift. | — |
| `generate-brewfiles.py` | Snapshot generator. Parses the `*.sh` scripts (for section headers, inline comments, and tombstones) and merges with `brew bundle dump --describe` output. Writes only the dated snapshot — the hand-curated Brewfiles are never touched. | — |

## Which file goes with which machine?

```sh
# Headless home server
brew bundle install --file=setup/homebrew/Brewfile.minimum
brew bundle install --file=setup/homebrew/Brewfile.homeserver

# Personal Mac (full desktop)
brew bundle install --file=setup/homebrew/Brewfile.minimum
brew bundle install --file=setup/homebrew/Brewfile.homeserver
brew bundle install --file=setup/homebrew/Brewfile.desktop
brew bundle install --file=setup/homebrew/Brewfile.games   # optional

# Work Mac
brew bundle install --file=setup/homebrew/Brewfile.minimum
brew bundle install --file=setup/homebrew/Brewfile.homeserver
brew bundle install --file=setup/homebrew/Brewfile.desktop
brew bundle install --file=setup/homebrew/Brewfile.work

# "What do I have set up across all my Macs?" — the master Brewfile.
# It is the union of all the layered files plus master-only entries
# (uv/go/cargo/post-install stuff that `brew bundle` can't express).
brew bundle install --file=setup/homebrew/Brewfile
```

## Why both formats?

- **The `*.sh` scripts are the curated journal.** They keep every commented-out entry, deprecation note, and historical comment. Run them to *install* a fresh machine end-to-end (they also handle post-install hooks like `pipx install llm`, `go install …/fabric/…`, `npm install -g …`, and the `curl … claude.ai/install.sh` step that Brewfiles can't express).
- **The Brewfiles are the declarative manifest.** They make `brew bundle check` work — one command to ask "what's missing on this machine?" or "what's installed but not in my manifest?" The `*.sh` scripts can't answer those questions.

## Daily usage

```sh
# What's missing on this machine compared to your master intent?
brew bundle check --file=setup/homebrew/Brewfile --no-upgrade

# Install everything in the master that isn't installed yet.
brew bundle install --file=setup/homebrew/Brewfile

# What's installed but NOT in the master? (drift report — does not modify)
brew bundle cleanup --file=setup/homebrew/Brewfile
```

On a fresh Mac, the typical flow is still the shell scripts (they run post-install hooks). For a quick declarative install, follow the cascade order above.

## Master vs. snapshots

The `Brewfile` master is yours — edit it freely, add things you *want* installed (even if not yet present), comment things out as historical notes. The generator will never touch it.

The generator produces a per-machine, per-day snapshot named `Brewfile.<hostname>.<YYYY-MM-DD>` that captures what's actually installed right now. Use it to:

- **diff against the master** to find drift in either direction (`diff Brewfile Brewfile.host.date`),
- **compare across machines** by running the generator on each and diffing the resulting snapshot files,
- **bootstrap or recover** the master from a known-good machine state (copy the snapshot over the master and edit from there).

## Generating a snapshot

Run any time to capture the current state of this machine:

```sh
brew bundle dump --describe --no-restart \
  --file=/tmp/Brewfile.generated --force
# Add --cargo and/or --uv only after you actually have crates / uv tools installed
# (the flags produce a broken empty dump when there's nothing to enumerate).
python3 setup/homebrew/generate-brewfiles.py
```

Output:
- `Brewfile.<hostname>.<YYYY-MM-DD>` — fresh snapshot (overwrites today's if it already exists)
- `Brewfile`, `Brewfile.minimum`, `Brewfile.homeserver`, `Brewfile.desktop`, `Brewfile.work`, `Brewfile.games` are hand-curated and **never** touched by the generator. Edit them directly.

The generator:

- Parses each `*.sh` script for section headers and inline `# comment` annotations.
- Reads `/tmp/Brewfile.generated` as the authoritative install list from this machine.
- Merges them so each entry carries the section header + your hand-written comment (falling back to Homebrew's stock description when you didn't write one).
- Annotates taps with the formula(e) they provide (e.g. `tap "Hyde46/hoard"  # for hoard`).
- Drops commented-out lines from the source scripts (the journal stays in the `*.sh` files; the Brewfile is a manifest).

## Classification rules (for editing the persona files)

Apply in order. First match wins. Use these when adding a new entry or deciding which file to put something in.

1. **Already in a lower layer (e.g. `Brewfile.minimum`)** → leave there only. Do not duplicate.
2. **Gaming cask or game-launcher** → `Brewfile.games`.
3. **`brew` formula (CLI/library/daemon)** → `Brewfile.homeserver`.
4. **`cask` GUI app** → `Brewfile.desktop` (or `Brewfile.work` if work-machine-only).
5. **`mas` App Store app** → `Brewfile.desktop`.
6. **`vscode` extensions** → `Brewfile.desktop` (cascade order ensures VS Code is installed first via `minimum`).
7. **`go`/`uv`/`npm`/post-install entries** → master `Brewfile` only — these aren't `brew bundle`-installable; the post-install hooks live in `brew.sh`/`brew-cask.sh`.
8. **Tombstoned/commented-out lines** → preserve them in whichever file the live entry would belong to.

## Known quirks

- **`brew bundle check` without `--no-upgrade` reports outdated-but-installed packages as "needs to be installed".** This is expected — append `--no-upgrade` if you only care about presence.
- **`Brewfile.minimum` may show items as missing.** This is expected when the *intent* (e.g. `microsoft-office` cask) doesn't match how the apps were actually installed on this machine (e.g. installed via Microsoft installer, not the brew cask). `check` is telling you the truth: the manifest and reality diverge.
- **`Brewfile.work` may show many failures.** It is currently a near-empty placeholder followed by a legacy journal. Edit the active section to whatever truly needs to be installed only on a work mac.
- **Post-install steps are not in any Brewfile.** `pipx install llm`, `llm install llm-mlx`, `go install … fabric …`, `npm install -g @mermaid-js/mermaid-cli`, and `curl … claude.ai/install.sh` all live in `brew.sh` / `brew-cask.sh` only. The Brewfile format has no equivalent.
- **Tier-based files are a separate axis.** `setup/state-sync/scripts/generate-tier-brewfile.sh` writes per-snapshot `Brewfile.essentials` / `Brewfile.regular` files that subset the master by *usage frequency* on a specific machine. Those are orthogonal to the role/persona files documented here.
