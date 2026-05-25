#!/usr/bin/env bash
# Requires bash 4+ for associative arrays. Use the Homebrew-installed bash
# rather than macOS's stock /bin/bash 3.2 (`brew install bash`).
#
# generate-tier-brewfile.sh
# Given a tier manifest, emits a Brewfile.<tier> subset that installs only the
# apps the user actually uses (from the captured usage data), plus auxiliary
# output for the few cases Brewfile can't express.
#
# Replaces generate-install-scripts.sh (which produced three bash scripts per
# tier via grep-parsing brew-cask.sh / brew.sh / mas.sh). This script reads
# the generated Brewfile snapshot instead — see setup/homebrew/Brewfile and
# generate-brewfiles.py. Tombstones (`# cask "X"`) in the snapshot let us
# preserve the "promote a manually-installed app" feature without re-parsing
# the source scripts.
#
# Outputs (under <snapshot_dir>/tiers/install/):
#   Brewfile.<tier>                  — primary install manifest
#   install-<tier>-manual.txt        — apps with no brew/mas line available
#   install-<tier>-promotions.txt    — audit log of `other` → brew/mas promotions
#   post-install-<tier>.sh           — only if any tier entries trigger a hook
#                                       (pipx/curl/etc — things Brewfile can't
#                                       express). Optional output.
#   summary-<tier>.txt
#
# Usage:
#   generate-tier-brewfile.sh [--tier essentials|regular|all]
#                             [--brewfile <path>]
#                             [snapshot_dir]
#
# If --brewfile is omitted, the latest generated snapshot in setup/homebrew/
# is used (Brewfile.<hostname>.<date>), falling back to the master Brewfile.

set -euo pipefail

TIER_LEVEL="essentials"
TARGET_SNAPSHOT_DIR=""
SOURCE_BREWFILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier)
            TIER_LEVEL="$2"
            shift 2
            ;;
        --brewfile)
            SOURCE_BREWFILE="$2"
            shift 2
            ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            TARGET_SNAPSHOT_DIR="$1"
            shift
            ;;
    esac
done

case "$TIER_LEVEL" in
    essentials|regular|all) ;;
    *) echo "Error: --tier must be essentials, regular, or all" >&2; exit 1 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# shellcheck source=lib-brewfile-parse.sh
source "$SCRIPT_DIR/lib-brewfile-parse.sh"

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required." >&2
    exit 1
fi

# Resolve source Brewfile
if [[ -z "$SOURCE_BREWFILE" ]]; then
    SOURCE_BREWFILE=$(find_latest_snapshot_brewfile) || {
        echo "Error: no Brewfile snapshot found in setup/homebrew/." >&2
        echo "Run: python3 setup/homebrew/generate-brewfiles.py" >&2
        exit 1
    }
fi
if [[ ! -f "$SOURCE_BREWFILE" ]]; then
    echo "Error: source Brewfile not found: $SOURCE_BREWFILE" >&2
    exit 1
fi

# Resolve snapshot dir
if [[ -z "$TARGET_SNAPSHOT_DIR" ]]; then
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    TARGET_SNAPSHOT_DIR=$(find "$SNAPSHOT_BASE" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
    if [[ -z "$TARGET_SNAPSHOT_DIR" ]]; then
        echo "Error: no snapshot dirs found under $SNAPSHOT_BASE" >&2
        exit 1
    fi
fi

TIERS_DIR="$TARGET_SNAPSHOT_DIR/tiers"
INSTALL_DIR="$TIERS_DIR/install"
mkdir -p "$INSTALL_DIR"

# Determine which tiers to include
INCLUDED_TIERS=()
case "$TIER_LEVEL" in
    essentials) INCLUDED_TIERS=("essentials") ;;
    regular)    INCLUDED_TIERS=("essentials" "regular") ;;
    all)        INCLUDED_TIERS=("essentials" "regular" "rare") ;;
esac

echo "Source Brewfile: $SOURCE_BREWFILE" >&2
echo "Snapshot:        $TARGET_SNAPSHOT_DIR" >&2
echo "Tier:            $TIER_LEVEL (includes: ${INCLUDED_TIERS[*]})" >&2
echo "Output:          $INSTALL_DIR" >&2

# Combine selected tier apps into one stream
APPS_JSON=$(mktemp)
trap 'rm -f "$APPS_JSON"' EXIT
{
    for tier in "${INCLUDED_TIERS[@]}"; do
        jq -c '.apps[]' "$TIERS_DIR/tier-${tier}.json"
    done
} | jq -s '.' > "$APPS_JSON"

TOTAL_APPS=$(jq 'length' "$APPS_JSON")
echo "Total apps in selected tier: $TOTAL_APPS" >&2

# Static post-install hook map: short cask/formula name -> commands to append
# to post-install-<tier>.sh when that name appears in the tier Brewfile.
# Sikarugir's --no-quarantine is NOT here — it goes inline in the Brewfile
# entry via `args: { no_quarantine: true }`.
declare -A POST_HOOKS=(
    [claude]='# Claude Code (Anthropic'\''s CLI). Brewfile installs the desktop app cask;
# the CLI is a separate curl-based installer.
curl -fsSL https://claude.ai/install.sh | bash'
    [pipx]='# Make sure pipx-installed binaries are on PATH.
pipx ensurepath'
    [llm]='# llm Python tool plus the MLX plugin (Apple Silicon LLM runner).
pipx install llm
llm install llm-mlx
llm install llm-gpt4all'
    [mlx-lm]='# Apple Silicon LLM runner used by llm-mlx.
pipx install mlx-lm'
)

# Casks that need `args: { no_quarantine: true }` to bypass Gatekeeper.
# Match by short name (everything after the last /).
NO_QUARANTINE_CASKS="sikarugir"

# Output files
BREWFILE_OUT="$INSTALL_DIR/Brewfile.${TIER_LEVEL}"
MANUAL_OUT="$INSTALL_DIR/install-${TIER_LEVEL}-manual.txt"
PROMOTIONS_OUT="$INSTALL_DIR/install-${TIER_LEVEL}-promotions.txt"
POST_INSTALL_OUT="$INSTALL_DIR/post-install-${TIER_LEVEL}.sh"
SUMMARY="$INSTALL_DIR/summary-${TIER_LEVEL}.txt"

GEN_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Initialize Brewfile.<tier>
{
    echo "# Brewfile.${TIER_LEVEL} — tier subset for state-sync provisioning."
    echo "# Generated by generate-tier-brewfile.sh on ${GEN_DATE}"
    echo "# Tier: ${TIER_LEVEL}"
    echo "# Source Brewfile: ${SOURCE_BREWFILE}"
    echo "# Source snapshot: ${TARGET_SNAPSHOT_DIR}"
    echo "#"
    echo "# Install with: brew bundle install --file=$(basename "$BREWFILE_OUT")"
    echo "# Inspect with: brew bundle check  --file=$(basename "$BREWFILE_OUT") --no-upgrade"
    echo ""
} > "$BREWFILE_OUT"

{
    echo "# Manual install list — Tier: ${TIER_LEVEL}"
    echo "# Generated ${GEN_DATE}"
    echo "# These apps need manual install (no brew/mas line found in source Brewfile)."
    echo "# Format: <app_name>\\t<original_path>"
    echo ""
} > "$MANUAL_OUT"

{
    echo "# Promotions — Tier: ${TIER_LEVEL}"
    echo "# Generated ${GEN_DATE}"
    echo "# These apps were classified as 'other' (manual install) but a brew/mas"
    echo "# line was found in the source Brewfile (active or tombstone). The matching"
    echo "# entry has been added to Brewfile.${TIER_LEVEL}. Remove unwanted lines if needed."
    echo "# Format: <kind>\\t<app_name>\\t<source>\\t<line>"
    echo ""
} > "$PROMOTIONS_OUT"

# Buffer arrays so we can emit grouped sections (casks / brews / mas) and
# dedupe within the tier.
declare -a CASK_LINES=()
declare -a BREW_LINES=()
declare -a MAS_LINES=()
declare -A SEEN_CASK=()
declare -A SEEN_BREW=()
declare -A SEEN_MAS=()
declare -A TIER_HOOKS=()  # short name -> 1 if hook applicable

# Emit a `cask "X"` line into the buffer, with optional inline args.
buffer_cask() {
    local short="$1" full="$2" trailing="${3:-}"
    [[ -n "${SEEN_CASK[$short]:-}" ]] && return
    SEEN_CASK[$short]=1
    local args=""
    case ",${NO_QUARANTINE_CASKS}," in
        *",${short},"*) args=', args: { no_quarantine: true }' ;;
    esac
    if [[ -n "$trailing" ]]; then
        CASK_LINES+=("cask \"${full}\"${args}  # ${trailing}")
    else
        CASK_LINES+=("cask \"${full}\"${args}")
    fi
    if [[ -n "${POST_HOOKS[$short]:-}" ]]; then
        TIER_HOOKS[$short]=1
    fi
}

buffer_brew() {
    local short="$1" full="$2" trailing="${3:-}"
    [[ -n "${SEEN_BREW[$short]:-}" ]] && return
    SEEN_BREW[$short]=1
    if [[ -n "$trailing" ]]; then
        BREW_LINES+=("brew \"${full}\"  # ${trailing}")
    else
        BREW_LINES+=("brew \"${full}\"")
    fi
    if [[ -n "${POST_HOOKS[$short]:-}" ]]; then
        TIER_HOOKS[$short]=1
    fi
}

buffer_mas() {
    local mas_id="$1" name="$2" trailing="${3:-}"
    [[ -n "${SEEN_MAS[$mas_id]:-}" ]] && return
    SEEN_MAS[$mas_id]=1
    if [[ -n "$trailing" ]]; then
        MAS_LINES+=("mas \"${name}\", id: ${mas_id}  # ${trailing}")
    else
        MAS_LINES+=("mas \"${name}\", id: ${mas_id}")
    fi
}

# Parse one line from the source Brewfile (active or tombstone) into the full
# package path. Strips `# ` prefix and inline comments.
extract_full_name() {
    local line="$1" kind="$2"
    # Strip leading "# " if present (tombstone)
    line="${line#\# }"
    # Strip the keyword and quote
    case "$kind" in
        cask) sed -E 's/^cask "([^"]+)".*/\1/' <<<"$line" ;;
        brew) sed -E 's/^brew "([^"]+)".*/\1/' <<<"$line" ;;
        mas)  sed -E 's/^mas "([^"]+)", id: ([0-9]+).*/\2/' <<<"$line" ;;
    esac
}

# Extract the trailing inline comment from a Brewfile line, if any.
# Returns text after the first `  #` (Brewfile convention is two spaces).
extract_inline_comment() {
    local line="$1"
    # Strip a leading `# ` if present (tombstone marker), then look for `  #`
    line="${line#\# }"
    if [[ "$line" == *"  #"* ]]; then
        # Everything after the first `  #`
        printf '%s\n' "${line#*  #}" | sed -E 's/^[[:space:]]+//'
    fi
}

# Normalize an app name to a likely cask short-name: lowercase, spaces→hyphens.
normalize() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g'
}

cask_count=0
brew_count=0
mas_count=0
manual_count=0
promo_count=0

while IFS= read -r app_record; do
    name=$(jq -r '.name' <<<"$app_record")
    install_type=$(jq -r '.install_type' <<<"$app_record")
    path=$(jq -r '.path' <<<"$app_record")
    tier=$(jq -r '.tier' <<<"$app_record")

    case "$install_type" in
        brew)
            cask=$(jq -r '.cask_name // empty' <<<"$app_record")
            [[ -z "$cask" ]] && continue
            result=$(brewfile_find_cask "$SOURCE_BREWFILE" "$cask" || true)
            if [[ -n "$result" ]]; then
                line="${result#*:}"
                full=$(extract_full_name "$line" cask)
                comment=$(extract_inline_comment "$line")
                buffer_cask "$cask" "$full" "$comment"
            else
                buffer_cask "$cask" "$cask" "[tier:$tier] auto-added (not in $SOURCE_BREWFILE)"
            fi
            cask_count=$((cask_count + 1))
            ;;
        mas)
            mas_id=$(jq -r '.mas_id // empty' <<<"$app_record")
            [[ -z "$mas_id" ]] && continue
            result=$(brewfile_find_mas_by_id "$SOURCE_BREWFILE" "$mas_id" || true)
            if [[ -z "$result" ]]; then
                result=$(brewfile_find_mas_by_name "$SOURCE_BREWFILE" "$name" || true)
            fi
            if [[ -n "$result" ]]; then
                line="${result#*:}"
                # Pull the display name from the existing entry
                display=$(sed -E 's/^#?[[:space:]]*mas "([^"]+)".*/\1/' <<<"$line")
                comment=$(extract_inline_comment "$line")
                buffer_mas "$mas_id" "$display" "$comment"
            else
                buffer_mas "$mas_id" "$name" "[tier:$tier] auto-added (not in $SOURCE_BREWFILE)"
            fi
            mas_count=$((mas_count + 1))
            ;;
        other)
            norm=$(normalize "$name")
            promoted=false

            # Try cask (most common): match active and tombstone.
            result=$(brewfile_find_cask "$SOURCE_BREWFILE" "$norm" || true)
            if [[ -n "$result" ]]; then
                kind="${result%%:*}"  # active or tombstone
                line="${result#*:}"
                full=$(extract_full_name "$line" cask)
                comment=$(extract_inline_comment "$line")
                buffer_cask "$norm" "$full" "promoted from manual: $name${comment:+; $comment}"
                printf 'cask\t%s\t%s\t%s\n' "$name" "$kind" "$line" >> "$PROMOTIONS_OUT"
                cask_count=$((cask_count + 1))
                promo_count=$((promo_count + 1))
                promoted=true
            else
                # Try brew formula (rare for GUI but possible).
                result=$(brewfile_find_brew "$SOURCE_BREWFILE" "$norm" || true)
                if [[ -n "$result" ]]; then
                    kind="${result%%:*}"
                    line="${result#*:}"
                    full=$(extract_full_name "$line" brew)
                    comment=$(extract_inline_comment "$line")
                    buffer_brew "$norm" "$full" "promoted from manual: $name${comment:+; $comment}"
                    printf 'brew\t%s\t%s\t%s\n' "$name" "$kind" "$line" >> "$PROMOTIONS_OUT"
                    brew_count=$((brew_count + 1))
                    promo_count=$((promo_count + 1))
                    promoted=true
                fi
            fi

            if [[ "$promoted" == "false" ]]; then
                # Try mas by name (case-insensitive in the lib).
                result=$(brewfile_find_mas_by_name "$SOURCE_BREWFILE" "$name" || true)
                if [[ -n "$result" ]]; then
                    kind="${result%%:*}"
                    line="${result#*:}"
                    display=$(sed -E 's/^#?[[:space:]]*mas "([^"]+)".*/\1/' <<<"$line")
                    mas_id=$(sed -E 's/^#?[[:space:]]*mas "[^"]+", id: ([0-9]+).*/\1/' <<<"$line")
                    comment=$(extract_inline_comment "$line")
                    buffer_mas "$mas_id" "$display" "promoted from manual: $name${comment:+; $comment}"
                    printf 'mas\t%s\t%s\t%s\n' "$name" "$kind" "$line" >> "$PROMOTIONS_OUT"
                    mas_count=$((mas_count + 1))
                    promo_count=$((promo_count + 1))
                    promoted=true
                fi
            fi

            if [[ "$promoted" == "false" ]]; then
                printf '%s\t%s\n' "$name" "$path" >> "$MANUAL_OUT"
                manual_count=$((manual_count + 1))
            fi
            ;;
    esac
done < <(jq -c '.[]' "$APPS_JSON")

# Emit grouped Brewfile.<tier> sections.
{
    if (( ${#BREW_LINES[@]} > 0 )); then
        echo "# Formulae"
        printf '%s\n' "${BREW_LINES[@]}" | sort
        echo ""
    fi
    if (( ${#CASK_LINES[@]} > 0 )); then
        echo "# Casks"
        printf '%s\n' "${CASK_LINES[@]}" | sort
        echo ""
    fi
    if (( ${#MAS_LINES[@]} > 0 )); then
        echo "# Mac App Store apps"
        printf '%s\n' "${MAS_LINES[@]}" | sort
        echo ""
    fi
} >> "$BREWFILE_OUT"

# Post-install hooks: emit only if any tier entry triggered one.
post_install_emitted=false
if (( ${#TIER_HOOKS[@]} > 0 )); then
    {
        echo "#!/usr/bin/env bash"
        echo "# post-install-${TIER_LEVEL}.sh"
        echo "# Generated by generate-tier-brewfile.sh on ${GEN_DATE}"
        echo "# Tier: ${TIER_LEVEL}"
        echo "#"
        echo "# Runs after \`brew bundle install --file=Brewfile.${TIER_LEVEL}\`. Each block"
        echo "# below is a side-effect that Brewfile can't express (pipx-installed tools,"
        echo "# curl-based installers, plugin installs)."
        echo "#"
        echo "# Re-runnable; errors are non-fatal."
        echo "FAILED=()"
        echo "__step() {"
        echo "    if ! eval \"\$1\"; then"
        echo "        FAILED+=(\"\$2\")"
        echo "        echo \"  [FAIL] \$2\" >&2"
        echo "    fi"
        echo "}"
        echo ""
        for short in $(printf '%s\n' "${!TIER_HOOKS[@]}" | sort); do
            echo "# --- ${short} ---"
            echo "${POST_HOOKS[$short]}"
            echo ""
        done
        echo ""
        echo "if (( \${#FAILED[@]} > 0 )); then"
        echo "    echo \"\""
        echo "    echo \"=========================================\""
        echo "    echo \"\${#FAILED[@]} post-install step(s) FAILED:\""
        echo "    printf '  %s\\n' \"\${FAILED[@]}\""
        echo "    echo \"=========================================\""
        echo "    exit 1"
        echo "fi"
        echo "echo \"All post-install steps completed.\""
    } > "$POST_INSTALL_OUT"
    chmod +x "$POST_INSTALL_OUT"
    post_install_emitted=true
fi

# Summary
{
    echo "========================================"
    echo "Tier Brewfile Generation — Tier: ${TIER_LEVEL}"
    echo "========================================"
    echo "Generated:       ${GEN_DATE}"
    echo "Source Brewfile: ${SOURCE_BREWFILE}"
    echo "Snapshot:        ${TARGET_SNAPSHOT_DIR}"
    echo ""
    echo "Output files:"
    echo "  $BREWFILE_OUT      (${cask_count} casks, ${brew_count} brews, ${mas_count} mas)"
    echo "  $MANUAL_OUT        ($manual_count manual entries)"
    echo "  $PROMOTIONS_OUT    ($promo_count promotions)"
    if [[ "$post_install_emitted" == "true" ]]; then
        echo "  $POST_INSTALL_OUT  (${#TIER_HOOKS[@]} hooks: ${!TIER_HOOKS[*]})"
    fi
    echo ""
    echo "Total apps processed: $TOTAL_APPS"
    echo "Total install actions: $((cask_count + brew_count + mas_count + manual_count))"
    echo ""
    if [[ "$promo_count" -gt 0 ]]; then
        echo "--- Promotions (sample) ---"
        head -10 "$PROMOTIONS_OUT" | tail -n +6
        echo ""
    fi
    if [[ "$manual_count" -gt 0 ]]; then
        echo "--- Manual installs still required (sample) ---"
        head -10 "$MANUAL_OUT" | tail -n +6
    fi
} > "$SUMMARY"

echo "" >&2
echo "Done. Summary:" >&2
cat "$SUMMARY"
