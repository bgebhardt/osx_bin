#!/bin/bash
#
# capture-app-usage.sh
# Captures application usage data from Spotlight metadata, Dock, and login items.
# Emits a ranked JSON manifest used as input to generate-app-tiers.sh.
#
# Output: app-usage.json with one entry per app, sorted by score descending.
# Usage: ./capture-app-usage.sh [output_dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: brew install jq" >&2
    exit 1
fi

if [[ -n "${1:-}" ]]; then
    OUTPUT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    OUTPUT_DIR="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
fi
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/app-usage.json"
SUMMARY_FILE="$OUTPUT_DIR/app-usage.txt"

DOCK_FILE=$(mktemp)
LOGIN_FILE=$(mktemp)
TSV_FILE=$(mktemp)
trap 'rm -f "$DOCK_FILE" "$LOGIN_FILE" "$TSV_FILE"' EXIT

echo "Capturing app usage state..." >&2
echo "Output: $OUTPUT_FILE" >&2

# ---- Dock pinned apps ----
echo "Reading Dock persistent apps..." >&2
defaults read com.apple.dock persistent-apps 2>/dev/null \
    | grep -oE 'file:///[^"]+\.app' \
    | while IFS= read -r url; do
        # URL-decode and strip trailing slash, take basename
        path_no_proto="${url#file://}"
        # decode %XX sequences
        decoded=$(printf '%b' "${path_no_proto//%/\\x}")
        decoded="${decoded%/}"
        basename "$decoded" .app
    done | sort -u > "$DOCK_FILE"

# ---- Login items ----
echo "Reading login items..." >&2
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null \
    | tr ',' '\n' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -v '^$' \
    | sort -u > "$LOGIN_FILE" || true

# ---- Enumerate apps and collect metadata ----
echo "Scanning /Applications, /Applications/Utilities, ~/Applications..." >&2
NOW_EPOCH=$(date +%s)

scan_app_dirs() {
    for dir in /Applications /Applications/Utilities "$HOME/Applications"; do
        [[ -d "$dir" ]] || continue
        find "$dir" -maxdepth 2 -name "*.app" -type d 2>/dev/null
    done
}

app_count=0
while IFS= read -r app_path; do
    [[ -z "$app_path" ]] && continue
    [[ -d "$app_path" ]] || continue

    app_name=$(basename "$app_path" .app)
    # Skip hidden/system helper bundles (e.g., .Karabiner-VirtualHIDDevice-Manager)
    [[ "$app_name" == .* ]] && continue
    app_count=$((app_count + 1))

    # Query Spotlight metadata (one call per app)
    mdls_out=$(mdls -name kMDItemLastUsedDate -name kMDItemUseCount "$app_path" 2>/dev/null || true)
    last_used_raw=$(awk -F' = ' '/kMDItemLastUsedDate/ {print $2; exit}' <<<"$mdls_out")
    use_count_raw=$(awk -F' = ' '/kMDItemUseCount/ {print $2; exit}' <<<"$mdls_out")

    # Parse last_used
    if [[ "$last_used_raw" == "(null)" || -z "$last_used_raw" ]]; then
        last_used_iso=""
        days_since=""
    else
        last_used_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$last_used_raw" "+%s" 2>/dev/null || echo "")
        if [[ -n "$last_used_epoch" ]]; then
            last_used_iso=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$last_used_raw" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
            days_since=$(( (NOW_EPOCH - last_used_epoch) / 86400 ))
        else
            last_used_iso=""
            days_since=""
        fi
    fi

    # Parse use_count
    if [[ "$use_count_raw" == "(null)" || -z "$use_count_raw" ]]; then
        use_count=0
    else
        use_count="$use_count_raw"
    fi

    # Pin signals
    in_dock=false
    if grep -qFx "$app_name" "$DOCK_FILE"; then in_dock=true; fi
    is_login=false
    if grep -qFx "$app_name" "$LOGIN_FILE"; then is_login=true; fi

    # Score = min(use_count, 100) + max(0, 100 - days_since) + 50*dock + 50*login
    score=0
    if [[ "$use_count" -gt 0 ]]; then
        if [[ "$use_count" -gt 100 ]]; then score=100; else score=$use_count; fi
    fi
    if [[ -n "$days_since" && "$days_since" -lt 100 ]]; then
        score=$(( score + 100 - days_since ))
    fi
    [[ "$in_dock" == "true" ]] && score=$(( score + 50 ))
    [[ "$is_login" == "true" ]] && score=$(( score + 50 ))

    # Emit TSV row (tabs separate fields; app names with tabs are vanishingly rare on macOS)
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$app_name" "$app_path" "$last_used_iso" "$days_since" "$use_count" "$in_dock" "$is_login" "$score" \
        >> "$TSV_FILE"
done < <(scan_app_dirs)

echo "Scanned $app_count apps." >&2

# ---- Build final JSON ----
echo "Building JSON..." >&2
jq -Rsn \
    --arg capture_date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg hostname "$(hostname)" \
    --arg user "$USER" \
    '{
      capture_date: $capture_date,
      hostname: $hostname,
      user: $user,
      apps: [
        inputs
        | split("\n")[]
        | select(length > 0)
        | split("\t")
        | {
            name: .[0],
            path: .[1],
            last_used: (if .[2] == "" then null else .[2] end),
            days_since_used: (if .[3] == "" then null else (.[3] | tonumber) end),
            use_count: (.[4] | tonumber),
            in_dock: (.[5] == "true"),
            is_login_item: (.[6] == "true"),
            score: (.[7] | tonumber)
          }
      ] | sort_by(-.score)
    }' < "$TSV_FILE" > "$OUTPUT_FILE"

# ---- Summary text ----
{
    echo "========================================"
    echo "App Usage Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo "Total apps scanned: $app_count"
    echo ""
    echo "Top 30 by score:"
    echo ""
    jq -r '.apps[:30][] | [.score, .use_count, (.days_since_used // "-"), (.in_dock | if . then "D" else "-" end), (.is_login_item | if . then "L" else "-" end), .name] | @tsv' "$OUTPUT_FILE" \
        | awk -F'\t' 'BEGIN{printf "%6s %7s %6s %s%s  %s\n", "SCORE", "USES", "DAYS", "D", "L", "NAME"} {printf "%6s %7s %6s %s%s  %s\n", $1, $2, $3, $4, $5, $6}'
    echo ""
    echo "Dock pinned: $(wc -l < "$DOCK_FILE" | tr -d ' ')"
    echo "Login items: $(wc -l < "$LOGIN_FILE" | tr -d ' ')"
} > "$SUMMARY_FILE"

echo "" >&2
echo "App usage captured successfully!" >&2
echo "JSON: $OUTPUT_FILE" >&2
echo "Summary: $SUMMARY_FILE" >&2
echo "" >&2
head -40 "$SUMMARY_FILE"
