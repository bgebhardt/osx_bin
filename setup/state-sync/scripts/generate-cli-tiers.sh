#!/bin/bash
#
# generate-cli-tiers.sh
# Reads cli-usage.json and ranks commands into three tiers by frequency:
#   cli-tier-essentials.json   top N_ESSENTIAL commands
#   cli-tier-regular.json      next N_REGULAR commands (excluding essentials)
#   cli-tier-rare.json         everything else
#
# Buckets are EXCLUSIVE.  Also emits cli-tiers-report.md with the full listing.
#
# Usage: generate-cli-tiers.sh [snapshot_dir]

set -euo pipefail

# Tunable rank thresholds (top-N)
N_ESSENTIAL=30
N_REGULAR=100

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required." >&2
    exit 1
fi

if [[ -n "${1:-}" ]]; then
    SNAPSHOT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    SNAPSHOT_DIR=$(find "$SNAPSHOT_BASE" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
    if [[ -z "$SNAPSHOT_DIR" ]]; then
        echo "Error: no snapshot dirs found under $SNAPSHOT_BASE" >&2
        exit 1
    fi
fi

CLI_FILE="$SNAPSHOT_DIR/cli-usage.json"
if [[ ! -f "$CLI_FILE" ]]; then
    echo "Error: $CLI_FILE not found. Run capture-cli-usage.sh first." >&2
    exit 1
fi

TIERS_DIR="$SNAPSHOT_DIR/cli-tiers"
mkdir -p "$TIERS_DIR"

echo "Snapshot:        $SNAPSHOT_DIR" >&2
echo "CLI usage file:  $CLI_FILE" >&2
echo "Tier output:     $TIERS_DIR" >&2
echo "Thresholds:      top $N_ESSENTIAL essentials, top $N_REGULAR regular, rest rare" >&2

GENERATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build combined intermediate with .tier annotation
jq -n \
    --slurpfile usage "$CLI_FILE" \
    --argjson n_essential "$N_ESSENTIAL" \
    --argjson n_regular "$N_REGULAR" \
    --arg generated_at "$GENERATED_AT" \
    '
    ($usage[0].commands | sort_by(-.count)) as $sorted
    |
    ($sorted
     | to_entries
     | map(
         .value + {
           rank: (.key + 1),
           tier: (
             if .key < $n_essential then "essentials"
             elif .key < $n_regular  then "regular"
             else "rare"
             end
           )
         }
       )
    ) as $ranked
    |
    {
      generated_at: $generated_at,
      snapshot: $usage[0].capture_date,
      hostname: $usage[0].hostname,
      total_invocations: $usage[0].total_invocations,
      source_files: $usage[0].source_files,
      thresholds: {n_essential: $n_essential, n_regular: $n_regular},
      tiers: {
        essentials: [$ranked[] | select(.tier == "essentials")],
        regular:    [$ranked[] | select(.tier == "regular")],
        rare:       [$ranked[] | select(.tier == "rare")]
      }
    }' > "$TIERS_DIR/_combined.json"

# Split per-tier files
for tier in essentials regular rare; do
    jq --arg t "$tier" '
      {
        tier: $t,
        generated_at: .generated_at,
        snapshot: .snapshot,
        hostname: .hostname,
        thresholds: .thresholds,
        count: (.tiers[$t] | length),
        commands: .tiers[$t]
      }
    ' "$TIERS_DIR/_combined.json" > "$TIERS_DIR/cli-tier-${tier}.json"
done

# ---- Markdown report ----
REPORT="$TIERS_DIR/cli-tiers-report.md"
{
    cat <<MD_HEAD
# CLI Usage Tier Report

**Generated:** ${GENERATED_AT}
**Snapshot:** $(jq -r '.snapshot' "$TIERS_DIR/_combined.json")
**Hostname:** $(jq -r '.hostname' "$TIERS_DIR/_combined.json")

## Sources

| File | Lines | Bytes |
|------|-------|-------|
MD_HEAD
    jq -r '.source_files[] | "| \(.path) | \(.lines) | \(.bytes) |"' "$TIERS_DIR/_combined.json"

    cat <<MD_THRESH

## Thresholds

- **essentials**: top ${N_ESSENTIAL} most-used commands
- **regular**: ranks ${N_ESSENTIAL}–${N_REGULAR}
- **rare**: rest

## Counts

| Tier | Commands |
|------|----------|
MD_THRESH
    total=0
    for tier in essentials regular rare; do
        c=$(jq '.count' "$TIERS_DIR/cli-tier-${tier}.json")
        printf '| %s | %d |\n' "$tier" "$c"
        total=$((total + c))
    done
    printf '| **Total** | **%d** |\n\n' "$total"

    for tier in essentials regular rare; do
        count=$(jq '.count' "$TIERS_DIR/cli-tier-${tier}.json")
        tier_cap="$(tr '[:lower:]' '[:upper:]' <<< "${tier:0:1}")${tier:1}"

        echo ""
        if [[ "$tier" == "rare" ]] && [[ "$count" -gt 30 ]]; then
            echo "## Rare ($count)"
            echo ""
            echo "Commands used infrequently. Probably not worth installing on a new Mac."
            echo ""
            echo "<details>"
            echo "<summary>Expand to see all $count rare commands</summary>"
            echo ""
        else
            echo "## ${tier_cap} ($count)"
            echo ""
            case "$tier" in
                essentials) echo "Top-frequency commands. Install these first on a new Mac." ;;
                regular)    echo "Mid-frequency commands." ;;
            esac
            echo ""
        fi

        echo "| Rank | Count | Type | Formula | Command |"
        echo "|------|-------|------|---------|---------|"
        jq -r '
          .commands[]
          | "| \(.rank)"
            + " | \(.count)"
            + " | \(.install_type)"
            + " | \(.formula // "-")"
            + " | `\(.name | gsub("\\|"; "\\|"))` |"
        ' "$TIERS_DIR/cli-tier-${tier}.json"

        if [[ "$tier" == "rare" ]] && [[ "$count" -gt 30 ]]; then
            echo ""
            echo "</details>"
        fi
    done

    # Note about noise from the capture step
    skipped_builtins=$(jq '.skipped_builtins | length' "$CLI_FILE")
    skipped_paths=$(jq '.skipped_relative_paths | length' "$CLI_FILE")
    unresolved=$(jq '.unresolved | length' "$CLI_FILE")
    cat <<MD_FOOT

## Capture notes

Excluded from this report (still recorded in \`cli-usage.json\` for inspection):

- **${skipped_builtins}** shell builtins/keywords/aliases (always available, no install needed)
- **${skipped_paths}** project-relative commands (e.g. \`./foo.sh\`, \`~/bin/...\`)
- **${unresolved}** unresolved/noise tokens (typos, JSON fragments from inline data, removed tools)
MD_FOOT
} > "$REPORT"

# Summary text for terminal
SUMMARY="$TIERS_DIR/cli-tiers-summary.txt"
{
    echo "========================================"
    echo "CLI Tier Generation"
    echo "========================================"
    echo "Generated: $GENERATED_AT"
    echo "Snapshot:  $(jq -r '.snapshot' "$TIERS_DIR/_combined.json")"
    echo ""
    echo "Counts:"
    for tier in essentials regular rare; do
        c=$(jq '.count' "$TIERS_DIR/cli-tier-${tier}.json")
        printf "  %-12s %d commands\n" "$tier:" "$c"
    done
    echo ""
    echo "========================================"
    echo "Essentials tier (top $N_ESSENTIAL)"
    echo "========================================"
    jq -r '.commands[] | "\(.rank)\t\(.count)\t\(.install_type)\t\(.formula // "-")\t\(.name)"' "$TIERS_DIR/cli-tier-essentials.json" \
        | awk -F'\t' 'BEGIN{printf "%4s %6s %-10s %-20s %s\n", "RANK", "COUNT", "TYPE", "FORMULA", "NAME"} {printf "%4s %6s %-10s %-20s %s\n", $1, $2, $3, $4, $5}'
} > "$SUMMARY"

rm -f "$TIERS_DIR/_combined.json"

echo "" >&2
echo "Done." >&2
echo "Files:" >&2
ls -la "$TIERS_DIR" >&2
echo "" >&2
echo "Markdown report: $REPORT" >&2
echo "" >&2
head -50 "$SUMMARY"
