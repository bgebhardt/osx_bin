#!/bin/bash
#
# generate-app-tiers.sh
# Reads app-usage.json + the classification index, and emits three tier manifests:
#   tier-essentials.json  (Dock, login items, or heavy + recent use)
#   tier-regular.json     (used at least once in last 90d, not in essentials)
#   tier-rare.json        (everything else)
#
# Buckets are EXCLUSIVE. Each app appears in exactly one tier.
# Layer 3 (generate-tier-brewfile.sh) can union them via the --tier flag.
#
# Usage: generate-app-tiers.sh [snapshot_dir]
#   If snapshot_dir is omitted, uses the most recent snapshot dir.

set -euo pipefail

# Tunable thresholds
ESSENTIAL_USE_COUNT_MIN=20
ESSENTIAL_RECENCY_DAYS=30
REGULAR_RECENCY_DAYS=90

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib-classify-app.sh"

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required." >&2
    exit 1
fi

# Resolve snapshot dir
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

USAGE_FILE="$SNAPSHOT_DIR/app-usage.json"
if [[ ! -f "$USAGE_FILE" ]]; then
    echo "Error: $USAGE_FILE not found. Run capture-app-usage.sh first." >&2
    exit 1
fi

TIERS_DIR="$SNAPSHOT_DIR/tiers"
mkdir -p "$TIERS_DIR"

echo "Snapshot dir:   $SNAPSHOT_DIR" >&2
echo "Usage file:     $USAGE_FILE" >&2
echo "Tier output:    $TIERS_DIR" >&2

# Build classification index
echo "Building classification index..." >&2
classify_app_init
trap classify_app_cleanup EXIT

# Merge classification into usage records, then split into tiers
echo "Generating tiers..." >&2

GENERATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq -n \
    --slurpfile usage "$USAGE_FILE" \
    --slurpfile classify "$CLASSIFY_INDEX" \
    --argjson essential_use_min "$ESSENTIAL_USE_COUNT_MIN" \
    --argjson essential_recency "$ESSENTIAL_RECENCY_DAYS" \
    --argjson regular_recency "$REGULAR_RECENCY_DAYS" \
    --arg generated_at "$GENERATED_AT" \
    '
    def tier_for(app):
        if app.in_dock or app.is_login_item then "essentials"
        elif (app.use_count >= $essential_use_min)
             and (app.days_since_used != null)
             and (app.days_since_used <= $essential_recency)
        then "essentials"
        elif (app.days_since_used != null)
             and (app.days_since_used <= $regular_recency)
        then "regular"
        else "rare"
        end;

    def enrich(app):
        app
        + ( $classify[0][app.name | ascii_downcase]
            // {install_type: "other"} )
        | . + {tier: tier_for(.)};

    ($usage[0].apps | map(enrich(.))) as $enriched
    |
    {
      generated_at: $generated_at,
      snapshot: $usage[0].capture_date,
      hostname: $usage[0].hostname,
      thresholds: {
        essential_use_count_min: $essential_use_min,
        essential_recency_days: $essential_recency,
        regular_recency_days: $regular_recency
      },
      tiers: {
        essentials: [$enriched[] | select(.tier == "essentials")],
        regular:    [$enriched[] | select(.tier == "regular")],
        rare:       [$enriched[] | select(.tier == "rare")]
      }
    }
    ' > "$TIERS_DIR/_combined.json"

# Split out one file per tier
for tier in essentials regular rare; do
    jq --arg t "$tier" '
      {
        tier: $t,
        generated_at: .generated_at,
        snapshot: .snapshot,
        hostname: .hostname,
        thresholds: .thresholds,
        count: (.tiers[$t] | length),
        apps: .tiers[$t]
      }
    ' "$TIERS_DIR/_combined.json" > "$TIERS_DIR/tier-${tier}.json"
done

# Apps that classify as "other" — manual installs, candidates for install-other-apps.sh
jq -r '
  [.tiers.essentials[], .tiers.regular[]]
  | map(select(.install_type == "other"))
  | sort_by(.name)
  | .[]
  | "\(.tier)\t\(.name)\t\(.path)"
' "$TIERS_DIR/_combined.json" > "$TIERS_DIR/unclassified.txt"

# Summary text
{
    echo "========================================"
    echo "App Tier Generation"
    echo "========================================"
    echo "Generated: $GENERATED_AT"
    echo "Snapshot:  $(jq -r '.snapshot' "$TIERS_DIR/_combined.json")"
    echo "Hostname:  $(jq -r '.hostname' "$TIERS_DIR/_combined.json")"
    echo ""
    echo "Thresholds:"
    echo "  essentials: in Dock OR login item OR (use_count >= $ESSENTIAL_USE_COUNT_MIN AND used <= $ESSENTIAL_RECENCY_DAYS days ago)"
    echo "  regular:    used <= $REGULAR_RECENCY_DAYS days ago"
    echo "  rare:       everything else"
    echo ""
    echo "Counts:"
    for tier in essentials regular rare; do
        count=$(jq '.count' "$TIERS_DIR/tier-${tier}.json")
        printf "  %-12s %d apps\n" "$tier:" "$count"
    done
    echo ""
    echo "Install-type breakdown (essentials + regular):"
    jq -r '
      [.tiers.essentials[], .tiers.regular[]]
      | group_by(.install_type)
      | map({type: .[0].install_type, count: length})
      | sort_by(-.count)
      | .[]
      | "  \(.type): \(.count)"
    ' "$TIERS_DIR/_combined.json"
    echo ""
    echo "========================================"
    echo "Essentials tier"
    echo "========================================"
    jq -r '.apps[] | "\(.install_type)\t\(.score)\t\(.use_count)\t\(.name)"' "$TIERS_DIR/tier-essentials.json" \
        | awk -F'\t' 'BEGIN{printf "%-7s %6s %7s  %s\n", "TYPE", "SCORE", "USES", "NAME"} {printf "%-7s %6s %7s  %s\n", $1, $2, $3, $4}'
    echo ""
    if [[ -s "$TIERS_DIR/unclassified.txt" ]]; then
        echo "========================================"
        echo "Unclassified apps in essentials/regular (not brew or mas)"
        echo "========================================"
        echo "These need manual install (or addition to install-other-apps.sh):"
        cat "$TIERS_DIR/unclassified.txt"
    fi
} > "$TIERS_DIR/summary.txt"

# Markdown report (full per-app listing, all three tiers)
REPORT_FILE="$TIERS_DIR/tiers-report.md"
{
    cat <<MD_HEADER
# App Tier Report

**Generated:** ${GENERATED_AT}
**Snapshot:** $(jq -r '.snapshot' "$TIERS_DIR/_combined.json")
**Hostname:** $(jq -r '.hostname' "$TIERS_DIR/_combined.json")

## Thresholds

- **essentials**: in Dock OR login item OR (\`use_count >= ${ESSENTIAL_USE_COUNT_MIN}\` AND used in last ${ESSENTIAL_RECENCY_DAYS} days)
- **regular**: used in last ${REGULAR_RECENCY_DAYS} days (not in essentials)
- **rare**: older or no usage data

Tiers are mutually exclusive — each app appears in exactly one tier.

## Counts

| Tier | Apps |
|------|------|
MD_HEADER

    total=0
    for tier in essentials regular rare; do
        count=$(jq '.count' "$TIERS_DIR/tier-${tier}.json")
        printf '| %s | %d |\n' "$tier" "$count"
        total=$((total + count))
    done
    printf '| **Total** | **%d** |\n\n' "$total"

    echo "### Install-type breakdown (essentials + regular)"
    echo ""
    echo "| Type | Count |"
    echo "|------|-------|"
    jq -r '
      [.tiers.essentials[], .tiers.regular[]]
      | group_by(.install_type)
      | map({type: .[0].install_type, count: length})
      | sort_by(-.count)
      | .[] | "| \(.type) | \(.count) |"
    ' "$TIERS_DIR/_combined.json"

    # Per-tier app listings
    for tier in essentials regular rare; do
        count=$(jq '.count' "$TIERS_DIR/tier-${tier}.json")
        echo ""
        case "$tier" in
            essentials) blurb="Apps in Dock, login items, or used frequently and recently." ;;
            regular)    blurb="Used in last ${REGULAR_RECENCY_DAYS} days but not in essentials." ;;
            rare)       blurb="Older or no Spotlight usage data. Likely safe to skip on a new Mac." ;;
        esac

        # Wrap the long `rare` tier in a collapsible details block
        if [[ "$tier" == "rare" ]] && [[ "$count" -gt 30 ]]; then
            echo "## Rare ($count)"
            echo ""
            echo "$blurb"
            echo ""
            echo "<details>"
            echo "<summary>Expand to see all $count rare apps</summary>"
            echo ""
        else
            # Capitalize first letter via bash parameter expansion
            tier_cap="$(tr '[:lower:]' '[:upper:]' <<< "${tier:0:1}")${tier:1}"
            echo "## ${tier_cap} ($count)"
            echo ""
            echo "$blurb"
            echo ""
        fi

        echo "| Name | Type | Score | Uses | Days | Dock | Login |"
        echo "|------|------|-------|------|------|------|-------|"
        jq -r '
          .apps
          | sort_by(-.score)
          | .[]
          | "| \(.name | gsub("\\|"; "\\|"))"
            + " | \(.install_type)"
            + " | \(.score)"
            + " | \(.use_count)"
            + " | \(.days_since_used // "-")"
            + " | \(if .in_dock then "✓" else "-" end)"
            + " | \(if .is_login_item then "✓" else "-" end) |"
        ' "$TIERS_DIR/tier-${tier}.json"

        if [[ "$tier" == "rare" ]] && [[ "$count" -gt 30 ]]; then
            echo ""
            echo "</details>"
        fi
    done

    # Manual install section
    if [[ -s "$TIERS_DIR/unclassified.txt" ]]; then
        echo ""
        echo "## Manual installs (essentials + regular tiers)"
        echo ""
        echo "These apps are NOT managed by brew or mas. \`generate-tier-brewfile.sh\` may still find a brew/mas line for them via name matching against the Brewfile snapshot (see promotions.txt)."
        echo ""
        echo "| Tier | Name | Path |"
        echo "|------|------|------|"
        awk -F'\t' '{printf "| %s | %s | `%s` |\n", $1, $2, $3}' "$TIERS_DIR/unclassified.txt"
    fi
} > "$REPORT_FILE"

# Drop the intermediate combined file
rm -f "$TIERS_DIR/_combined.json"

echo "" >&2
echo "Done." >&2
echo "Output files:" >&2
ls -la "$TIERS_DIR" >&2
echo "" >&2
echo "Markdown report: $REPORT_FILE" >&2
echo "" >&2
head -50 "$TIERS_DIR/summary.txt"
