#!/bin/bash
#
# apply-on-remote.sh
# Runs on the target Mac to apply a state-sync bundle delivered by push-to-mac.sh.
# The bundle is expected to live in the same directory as this script.
#
# Stages (each opt-in via prompt):
#   1. Verify / install Homebrew
#   2. Install brew formulae from install-<tier>-brew.sh
#   3. Install brew casks from install-<tier>-brew-cask.sh
#   4. Install Mac App Store apps from install-<tier>-mas.sh
#   5. Print manual install list
#   6. (--include configs) Copy app configs (Karabiner, Rectangle, etc.)
#   7. (--include defaults) Run mac-defaults.sh
#   8. (--include prefs)    Run restore-app-prefs.sh
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

# Detect tier from filenames
TIER=""
for f in "$BUNDLE_DIR"/install/install-*-brew-cask.sh; do
    [[ -f "$f" ]] || continue
    fname=$(basename "$f")
    TIER="${fname#install-}"
    TIER="${TIER%-brew-cask.sh}"
    break
done
if [[ -z "$TIER" ]]; then
    echo "Error: cannot detect tier (no install/install-*-brew-cask.sh found)" >&2
    exit 1
fi
echo "Detected tier: $TIER"
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
echo "=== Stage 1: Homebrew ==="
if command -v brew &>/dev/null; then
    echo "  Homebrew already installed: $(brew --version | head -1)"
else
    echo "  Homebrew not found."
    if confirm "Install Homebrew now?"; then
        run_or_dry /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Set PATH for this session
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "  Skipping Homebrew install. brew/mas/cask stages will be unavailable."
    fi
fi
echo ""

# ---- Stage 2: brew formulae ----
echo "=== Stage 2: brew formulae ==="
BREW_SCRIPT="$BUNDLE_DIR/install/install-${TIER}-brew.sh"
if [[ -f "$BREW_SCRIPT" ]]; then
    count=$(grep -cE '^[[:space:]]*brew install ' "$BREW_SCRIPT" || true)
    echo "  Script: $BREW_SCRIPT ($count formulae)"
    if [[ "$count" -gt 0 ]] && confirm "Run brew formula installs?"; then
        if command -v brew &>/dev/null; then
            run_or_dry bash "$BREW_SCRIPT" || echo "  (some formulae failed; continuing)"
        else
            echo "  brew not on PATH; skipping"
        fi
    fi
else
    echo "  No brew script in bundle, skipping."
fi
echo ""

# ---- Stage 3: brew casks ----
echo "=== Stage 3: brew casks ==="
CASK_SCRIPT="$BUNDLE_DIR/install/install-${TIER}-brew-cask.sh"
if [[ -f "$CASK_SCRIPT" ]]; then
    count=$(grep -cE '^[[:space:]]*brew install ' "$CASK_SCRIPT" || true)
    echo "  Script: $CASK_SCRIPT ($count casks)"
    if [[ "$count" -gt 0 ]] && confirm "Run brew cask installs?"; then
        if command -v brew &>/dev/null; then
            run_or_dry bash "$CASK_SCRIPT" || echo "  (some casks failed; continuing)"
        else
            echo "  brew not on PATH; skipping"
        fi
    fi
else
    echo "  No cask script in bundle, skipping."
fi
echo ""

# ---- Stage 4: Mac App Store ----
echo "=== Stage 4: Mac App Store ==="
MAS_SCRIPT="$BUNDLE_DIR/install/install-${TIER}-mas.sh"
if [[ -f "$MAS_SCRIPT" ]]; then
    count=$(grep -cE '^[[:space:]]*mas install ' "$MAS_SCRIPT" || true)
    echo "  Script: $MAS_SCRIPT ($count apps)"
    if [[ "$count" -gt 0 ]]; then
        if ! command -v mas &>/dev/null; then
            echo "  mas not installed."
            if confirm "Install mas via brew?"; then
                run_or_dry brew install mas
            fi
        fi
        if command -v mas &>/dev/null; then
            if mas account &>/dev/null; then
                signed_in=$(mas account 2>&1 | head -1)
                echo "  App Store signed in as: $signed_in"
            else
                echo "  Not signed into Mac App Store."
                echo "  Please open App Store.app and sign in, then re-run with --tier mas only."
            fi
            if confirm "Run mas installs now?"; then
                run_or_dry bash "$MAS_SCRIPT" || echo "  (some mas installs failed; continuing)"
            fi
        else
            echo "  mas unavailable; skipping."
        fi
    fi
else
    echo "  No mas script in bundle, skipping."
fi
echo ""

# ---- Stage 5: manual installs ----
echo "=== Stage 5: Manual installs ==="
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

# ---- Stage 6: app configs ----
echo "=== Stage 6: App configs ==="
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

# ---- Stage 7: macOS defaults ----
echo "=== Stage 7: macOS defaults ==="
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

# ---- Stage 8: app prefs ----
echo "=== Stage 8: App preferences (plist imports) ==="
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
