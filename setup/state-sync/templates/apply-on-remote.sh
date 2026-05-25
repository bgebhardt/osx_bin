#!/bin/bash
#
# apply-on-remote.sh
# Runs on the target Mac to apply a state-sync bundle delivered by push-to-mac.sh.
# The bundle is expected to live in the same directory as this script.
#
# Stages (each opt-in via prompt):
#   1. Verify / install Homebrew
#   2. Preview Brewfile.<tier> via `brew bundle check`
#   3. Install brew formulae   (brew bundle install --no-cask --no-mas --no-vscode)
#   4. Install brew casks      (brew bundle install --no-brew --no-mas --no-vscode)
#   5. Install Mac App Store   (brew bundle install --no-brew --no-cask --no-vscode)
#   6. Run post-install-<tier>.sh   (pipx/curl steps that Brewfile can't express)
#   7. Print manual install list
#   8. (--include configs) Copy app configs (Karabiner, Rectangle, etc.)
#   9. (--include defaults) Run mac-defaults.sh
#  10. (--include prefs)    Run restore-app-prefs.sh
#
# Usage: apply-on-remote.sh [--all-yes] [--dry-run]
#   --all-yes   Accept every prompt (use with caution)
#   --dry-run   Print what would happen without doing it

set -uo pipefail   # NOTE: not -e — we want to continue past per-stage failures

ALL_YES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all-yes) ALL_YES=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "========================================"
echo "State-Sync Apply on Remote"
echo "========================================"
echo "Bundle: $BUNDLE_DIR"
echo "Host:   $(hostname)"
[[ "$DRY_RUN" == "true" ]] && echo "Mode:   DRY-RUN"
[[ "$ALL_YES" == "true" ]] && echo "Mode:   --all-yes (no confirmation prompts)"
echo ""

if [[ -f "$BUNDLE_DIR/MANIFEST.txt" ]]; then
    echo "--- Bundle Manifest ---"
    cat "$BUNDLE_DIR/MANIFEST.txt"
    echo ""
fi

# Detect tier from filenames: install/Brewfile.<tier>
TIER=""
BREWFILE=""
for f in "$BUNDLE_DIR"/install/Brewfile.*; do
    [[ -f "$f" ]] || continue
    fname=$(basename "$f")
    TIER="${fname#Brewfile.}"
    BREWFILE="$f"
    break
done
if [[ -z "$TIER" ]]; then
    echo "Error: cannot detect tier (no install/Brewfile.* found)" >&2
    exit 1
fi
echo "Detected tier: $TIER"
echo "Brewfile:      $BREWFILE"
echo ""

confirm() {
    local prompt="$1"
    [[ "$ALL_YES" == "true" ]] && return 0
    read -r -p "$prompt [y/N] " ans
    case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

run_or_dry() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [dry-run] $*"
        return 0
    fi
    "$@"
}

# ---- Stage 1: Homebrew ----
# Check PATH first, then the well-known install locations. Non-login SSH
# sessions often don't have /opt/homebrew/bin on PATH even when brew exists.
echo "=== Stage 1: Homebrew ==="
BREW=""
if command -v brew &>/dev/null; then
    BREW="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
    BREW="/opt/homebrew/bin/brew"
    eval "$("$BREW" shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    BREW="/usr/local/bin/brew"
    eval "$("$BREW" shellenv)"
fi

if [[ -n "$BREW" ]]; then
    echo "  Homebrew already installed at: $BREW"
    echo "  Version: $("$BREW" --version | head -1)"
    echo "  → skipping install."
else
    echo "  Homebrew not found in PATH or /opt/homebrew/bin or /usr/local/bin."
    if confirm "Install Homebrew now?"; then
        run_or_dry /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Bring brew onto PATH for the rest of this session
        if [[ -x /opt/homebrew/bin/brew ]]; then
            BREW="/opt/homebrew/bin/brew"
            eval "$("$BREW" shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            BREW="/usr/local/bin/brew"
            eval "$("$BREW" shellenv)"
        fi
    else
        echo "  Skipping Homebrew install. brew/mas/cask stages will be unavailable."
    fi
fi
echo ""

# Common counts from Brewfile (used by stages 2-5).
brew_count=$(grep -cE '^brew "' "$BREWFILE" || true)
cask_count=$(grep -cE '^cask "' "$BREWFILE" || true)
mas_count=$(grep -cE '^mas "' "$BREWFILE" || true)

# ---- Stage 2: Preview Brewfile ----
echo "=== Stage 2: Preview Brewfile.$TIER ==="
echo "  Entries: $brew_count formulae, $cask_count casks, $mas_count mas apps"
if command -v brew &>/dev/null && confirm "Run \`brew bundle check\` to preview what's missing?"; then
    # --no-upgrade: report only missing, not outdated.
    "$BREW" bundle check --file="$BREWFILE" --no-upgrade --verbose || true
fi
echo ""

# ---- Stage 3: brew formulae ----
echo "=== Stage 3: brew formulae ($brew_count) ==="
if [[ "$brew_count" -gt 0 ]] && confirm "Install brew formulae?"; then
    if command -v brew &>/dev/null; then
        run_or_dry "$BREW" bundle install --file="$BREWFILE" \
            --no-upgrade --no-cask --no-mas --no-vscode \
            || echo "  (some formulae failed; continuing)"
    else
        echo "  brew not on PATH; skipping"
    fi
fi
echo ""

# ---- Stage 4: brew casks ----
echo "=== Stage 4: brew casks ($cask_count) ==="
if [[ "$cask_count" -gt 0 ]] && confirm "Install brew casks?"; then
    if command -v brew &>/dev/null; then
        run_or_dry "$BREW" bundle install --file="$BREWFILE" \
            --no-upgrade --no-brew --no-mas --no-vscode \
            || echo "  (some casks failed; continuing)"
    else
        echo "  brew not on PATH; skipping"
    fi
fi
echo ""

# ---- Stage 5: Mac App Store ----
echo "=== Stage 5: Mac App Store ($mas_count) ==="
if [[ "$mas_count" -gt 0 ]]; then
    if ! command -v mas &>/dev/null; then
        echo "  mas not installed."
        if confirm "Install mas via brew?"; then
            run_or_dry "$BREW" install mas
        fi
    fi
    if command -v mas &>/dev/null; then
        if mas account &>/dev/null; then
            signed_in=$(mas account 2>&1 | head -1)
            echo "  App Store signed in as: $signed_in"
        else
            echo "  Not signed into Mac App Store."
            echo "  Please open App Store.app and sign in, then re-run this stage."
        fi
        if confirm "Run mas installs now?"; then
            run_or_dry "$BREW" bundle install --file="$BREWFILE" \
                --no-upgrade --no-brew --no-cask --no-vscode \
                || echo "  (some mas installs failed; continuing)"
        fi
    else
        echo "  mas unavailable; skipping."
    fi
fi
echo ""

# ---- Stage 6: post-install hooks ----
echo "=== Stage 6: Post-install hooks ==="
POST_INSTALL="$BUNDLE_DIR/install/post-install-${TIER}.sh"
if [[ -f "$POST_INSTALL" ]]; then
    echo "  Script: $POST_INSTALL"
    echo "  These are side-effects Brewfile can't express (pipx installs, curl-based installers, …)."
    if confirm "Run post-install hooks?"; then
        run_or_dry bash "$POST_INSTALL" || echo "  (some post-install steps failed; continuing)"
    fi
else
    echo "  No post-install script in bundle, skipping."
fi
echo ""

# ---- Stage 7: manual installs ----
echo "=== Stage 7: Manual installs ==="
MANUAL_FILE="$BUNDLE_DIR/install/install-${TIER}-manual.txt"
if [[ -f "$MANUAL_FILE" ]]; then
    body_lines=$(grep -cv '^#\|^$' "$MANUAL_FILE" || echo 0)
    echo "  $body_lines apps still need manual install."
    echo "  See: $MANUAL_FILE"
    echo ""
    echo "  --- Manual install list ---"
    grep -v '^#' "$MANUAL_FILE" | grep -v '^$' || true
else
    echo "  No manual install file in bundle."
fi
echo ""

# ---- Stage 8: app configs ----
echo "=== Stage 8: App configs ==="
if [[ -d "$BUNDLE_DIR/configs" ]]; then
    echo "  Configs dir: $BUNDLE_DIR/configs"
    ls -1 "$BUNDLE_DIR/configs" | sed 's/^/    /'
    if confirm "Copy app configs into their normal locations?"; then
        # Karabiner
        if [[ -d "$BUNDLE_DIR/configs/karabiner" ]]; then
            target="$HOME/.config/karabiner"
            run_or_dry mkdir -p "$target"
            run_or_dry rsync -av "$BUNDLE_DIR/configs/karabiner/" "$target/"
        fi
        # Rectangle
        if [[ -f "$BUNDLE_DIR/configs/RectangleConfig.json" ]]; then
            echo "  Note: import RectangleConfig.json via Rectangle prefs > Import"
            echo "  File ready at: $BUNDLE_DIR/configs/RectangleConfig.json"
        fi
        # Raycast - .rayconfig must be imported via Raycast UI
        for rayfile in "$BUNDLE_DIR/configs/"*.rayconfig; do
            [[ -f "$rayfile" ]] || continue
            echo "  Note: import Raycast config via: open '$rayfile' (Raycast handles .rayconfig)"
        done
    fi
else
    echo "  No configs in bundle, skipping."
fi
echo ""

# ---- Stage 9: macOS defaults ----
echo "=== Stage 9: macOS defaults ==="
if [[ -f "$BUNDLE_DIR/mac-defaults.sh" ]]; then
    echo "  Script: $BUNDLE_DIR/mac-defaults.sh"
    echo "  WARNING: this sets dozens of system defaults. Review the script first."
    if confirm "Run mac-defaults.sh?"; then
        run_or_dry bash "$BUNDLE_DIR/mac-defaults.sh"
    fi
else
    echo "  No mac-defaults.sh in bundle, skipping."
fi
echo ""

# ---- Stage 10: app prefs ----
echo "=== Stage 10: App preferences (plist imports) ==="
if [[ -d "$BUNDLE_DIR/app-plists" ]] && [[ -f "$BUNDLE_DIR/restore-app-prefs.sh" ]]; then
    plist_count=$(find "$BUNDLE_DIR/app-plists" -name '*.plist' | wc -l | tr -d ' ')
    echo "  $plist_count plist(s) available"
    if [[ "$plist_count" -gt 0 ]] && confirm "Restore app preferences?"; then
        flag=""
        [[ "$DRY_RUN" == "true" ]] && flag="--dry-run"
        [[ "$ALL_YES" == "true" ]] && flag="$flag --all"
        # restore script expects a snapshot dir layout (with app-plists/ inside it)
        run_or_dry bash "$BUNDLE_DIR/restore-app-prefs.sh" $flag "$BUNDLE_DIR"
    fi
else
    echo "  No plist exports in bundle, skipping."
fi
echo ""

echo "========================================"
echo "Done."
echo "Bundle preserved at: $BUNDLE_DIR"
echo "========================================"
