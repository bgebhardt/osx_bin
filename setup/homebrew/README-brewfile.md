# Brewfiles — declarative manifest for `brew bundle`

This directory now contains both the original imperative shell scripts (`brew.sh`, `brew-cask.sh`, `brew-cask-minimum.sh`, `brew-cask-work.sh`, `brew-work.sh`) **and** a set of declarative Brewfiles for use with `brew bundle`. They coexist — neither replaces the other.

| File | Purpose |
| --- | --- |
| `Brewfile` | Full manifest of everything currently installed on this Mac (taps, formulae, casks, mas apps, VS Code extensions). |
| `Brewfile.minimum` | The "fresh-machine essentials" set — mirrors `brew-cask-minimum.sh`. |
| `Brewfile.work` | Work-machine overlay — mirrors `brew-cask-work.sh` + `brew-work.sh`. Both source scripts are older; expect many entries to be stale. |
| `generate-brewfiles.py` | Regenerator. Parses the `*.sh` scripts and merges with `brew bundle dump --describe` output. |

## Why both formats?

- **The `*.sh` scripts are the curated journal.** They keep every commented-out entry, deprecation note, and historical comment. Run them to *install* a fresh machine end-to-end (they also handle post-install hooks like `pipx install llm`, `go install …/fabric/…`, `npm install -g …`, and the `curl … claude.ai/install.sh` step that Brewfiles can't express).
- **The Brewfiles are the declarative manifest.** They make `brew bundle check` work — one command to ask "what's missing on this machine?" or "what's installed but not in my manifest?" The `*.sh` scripts can't answer those questions.

## Daily usage

```sh
# What's missing or out of date on this machine?
brew bundle check  --file=setup/homebrew/Brewfile

# Same, but ignore "outdated" — only report presence.
brew bundle check  --file=setup/homebrew/Brewfile --no-upgrade

# Install everything missing.
brew bundle install --file=setup/homebrew/Brewfile

# What's installed but NOT in the manifest? (drift report — does not modify)
brew bundle cleanup --file=setup/homebrew/Brewfile
```

On a fresh Mac, the typical flow is still the shell scripts (they run post-install hooks). Use `Brewfile.minimum` if you want a fast `brew bundle install --file=Brewfile.minimum` for the essentials only.

## Regenerating after editing the `*.sh` scripts

When you add or remove items in `brew.sh` / `brew-cask.sh`, refresh the Brewfiles:

```sh
brew bundle dump --describe --no-restart \
  --file=/tmp/Brewfile.generated --force
# Add --cargo and/or --uv only after you actually have crates / uv tools installed
# (the flags produce a broken empty dump when there's nothing to enumerate).
python3 setup/homebrew/generate-brewfiles.py
```

The generator:

- Parses each `*.sh` script for section headers and inline `# comment` annotations.
- Reads `/tmp/Brewfile.generated` as the authoritative install list from this machine.
- Merges them so each Brewfile entry carries the section header + your hand-written comment (falling back to Homebrew's stock description when you didn't write one).
- Annotates taps with the formula(e) they provide (e.g. `tap "Hyde46/hoard"  # for hoard`).
- Drops commented-out lines from the source scripts (the journal stays in the `*.sh` files; the Brewfile is a manifest).

## Known quirks

- **`brew bundle check` without `--no-upgrade` reports outdated-but-installed packages as "needs to be installed".** This is expected — append `--no-upgrade` if you only care about presence.
- **`Brewfile.minimum` may show items as missing.** This is expected when the *intent* in `brew-cask-minimum.sh` (e.g. `microsoft-office` cask) doesn't match how the apps were actually installed on this machine (e.g. installed via Microsoft installer, not the brew cask). `check` is telling you the truth: the manifest and reality diverge.
- **`Brewfile.work` will show many failures.** The work source scripts are older overlays (`brew-work.sh` literally says "OLD ITEMS TO REMOVE BELOW HERE"). Most entries no longer exist as casks. Treat the file as a historical reference and prune as you go.
- **Post-install steps are not in any Brewfile.** `pipx install llm`, `llm install llm-mlx`, `go install … fabric …`, `npm install -g @mermaid-js/mermaid-cli`, and `curl … claude.ai/install.sh` all live in `brew.sh` / `brew-cask.sh` only. The Brewfile format has no equivalent.
