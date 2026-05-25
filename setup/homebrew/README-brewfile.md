# Brewfiles — declarative manifest for `brew bundle`

This directory now contains both the original imperative shell scripts (`brew.sh`, `brew-cask.sh`, `brew-cask-minimum.sh`, `brew-cask-work.sh`, `brew-work.sh`) **and** a set of declarative Brewfiles for use with `brew bundle`. They coexist — neither replaces the other.

| File | Purpose |
| --- | --- |
| `Brewfile` | **Hand-curated master.** Never overwritten by the generator. Your declared intent across machines. |
| `Brewfile.<host>.<YYYY-MM-DD>` | Per-machine, per-day snapshot of what's *actually* installed. Generated. Diff against the master to see drift. |
| `Brewfile.minimum` | "Fresh-machine essentials" — mirrors `brew-cask-minimum.sh`. Generated. |
| `Brewfile.work` | Work-machine overlay — mirrors `brew-cask-work.sh` + `brew-work.sh`. Generated; expect stale entries. |
| `generate-brewfiles.py` | Regenerator. Parses the `*.sh` scripts and merges with `brew bundle dump --describe` output. Writes everything **except** the master. |

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

On a fresh Mac, the typical flow is still the shell scripts (they run post-install hooks). Use `Brewfile.minimum` for a fast `brew bundle install --file=Brewfile.minimum` of just the essentials.

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
- `Brewfile.minimum` and `Brewfile.work` — regenerated from the `*.sh` source scripts
- The `Brewfile` master is **not** touched

The generator:

- Parses each `*.sh` script for section headers and inline `# comment` annotations.
- Reads `/tmp/Brewfile.generated` as the authoritative install list from this machine.
- Merges them so each entry carries the section header + your hand-written comment (falling back to Homebrew's stock description when you didn't write one).
- Annotates taps with the formula(e) they provide (e.g. `tap "Hyde46/hoard"  # for hoard`).
- Drops commented-out lines from the source scripts (the journal stays in the `*.sh` files; the Brewfile is a manifest).

## Known quirks

- **`brew bundle check` without `--no-upgrade` reports outdated-but-installed packages as "needs to be installed".** This is expected — append `--no-upgrade` if you only care about presence.
- **`Brewfile.minimum` may show items as missing.** This is expected when the *intent* in `brew-cask-minimum.sh` (e.g. `microsoft-office` cask) doesn't match how the apps were actually installed on this machine (e.g. installed via Microsoft installer, not the brew cask). `check` is telling you the truth: the manifest and reality diverge.
- **`Brewfile.work` will show many failures.** The work source scripts are older overlays (`brew-work.sh` literally says "OLD ITEMS TO REMOVE BELOW HERE"). Most entries no longer exist as casks. Treat the file as a historical reference and prune as you go.
- **Post-install steps are not in any Brewfile.** `pipx install llm`, `llm install llm-mlx`, `go install … fabric …`, `npm install -g @mermaid-js/mermaid-cli`, and `curl … claude.ai/install.sh` all live in `brew.sh` / `brew-cask.sh` only. The Brewfile format has no equivalent.
