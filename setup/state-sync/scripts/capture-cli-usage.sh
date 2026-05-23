#!/bin/bash
#
# capture-cli-usage.sh
# Captures CLI command usage from shell history files. Counts frequency per
# command, classifies each as brew / system / other, and writes cli-usage.json.
#
# Skipped categories (still recorded in JSON under their respective keys so
# you can see what was excluded):
#   - shell builtins / keywords / functions / aliases (resolved via `type`)
#   - core macOS binaries in /bin /sbin /usr/bin /usr/sbin
#   - relative paths (./foo) and absolute project paths (~/bin/...)
#
# Output: <snapshot_dir>/cli-usage.json + cli-usage.txt
# Usage: ./capture-cli-usage.sh [output_dir]

set -euo pipefail

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
    OUTPUT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    OUTPUT_DIR="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
fi
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/cli-usage.json"
SUMMARY_FILE="$OUTPUT_DIR/cli-usage.txt"

echo "Capturing CLI usage state..." >&2

# ---- Discover history sources ----
HIST_SOURCES=()
HIST_META_JSON="[]"
for f in "$HOME/.bash_history" "$HOME/.zsh_history"; do
    if [[ -f "$f" ]]; then
        HIST_SOURCES+=("$f")
        lines=$(wc -l <"$f" | tr -d ' ')
        size=$(wc -c <"$f" | tr -d ' ')
        HIST_META_JSON=$(jq --arg p "$f" --argjson l "$lines" --argjson s "$size" \
            '. + [{path: $p, lines: $l, bytes: $s}]' <<<"$HIST_META_JSON")
    fi
done

if [[ ${#HIST_SOURCES[@]} -eq 0 ]]; then
    echo "  No history files found." >&2
    # Emit empty-but-valid JSON
    jq -n --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg h "$(hostname)" --arg u "$USER" \
        '{capture_date: $t, hostname: $h, user: $u, source_files: [],
          total_invocations: 0, unique_commands: 0, commands: [],
          skipped_builtins: [], skipped_paths: []}' > "$OUTPUT_FILE"
    echo "CLI usage captured successfully!" >&2
    exit 0
fi

echo "  Sources: ${HIST_SOURCES[*]}" >&2

# ---- Step 1: parse frequencies (one awk pass over all history files) ----
FREQ_TSV=$(mktemp)
SKIP_PATH_TSV=$(mktemp)
trap 'rm -f "$FREQ_TSV" "$SKIP_PATH_TSV"' EXIT

awk '
{
    line = $0
    # zsh extended history: ": <unix_ts>:<duration>;<command>"
    if (line ~ /^: [0-9]+:[0-9]+;/) {
        sub(/^: [0-9]+:[0-9]+;/, "", line)
    }
    sub(/^[ \t]+/, "", line)
    if (line == "" || line ~ /^#/) next
    # Strip leading "$ " prompt artifacts and sudo
    sub(/^\$[ \t]+/, "", line)
    sub(/^sudo[ \t]+/, "", line)
    # Strip env var assignments (FOO=bar BAZ=qux command ...)
    while (line ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
        if (!sub(/^[^[:space:]]+[[:space:]]+/, "", line)) break
    }
    # First token before any shell metachar
    n = split(line, parts, /[ \t;|&<>()]/)
    cmd = parts[1]
    if (cmd == "") next
    # Project-relative / absolute path commands — record separately
    if (cmd ~ /^[.\/~]/) {
        path_counts[cmd]++
        next
    }
    # Skip flags
    if (cmd ~ /^-/) next
    counts[cmd]++
}
END {
    for (c in counts) print counts[c] "\t" c > "/dev/stdout"
    for (p in path_counts) print path_counts[p] "\t" p > "/dev/stderr"
}
' "${HIST_SOURCES[@]}" 2>"$SKIP_PATH_TSV" | sort -rn > "$FREQ_TSV"

TOTAL_INVOCATIONS=$(awk '{s+=$1} END {print s+0}' "$FREQ_TSV")
UNIQUE_COMMANDS=$(wc -l <"$FREQ_TSV" | tr -d ' ')
echo "  Parsed $TOTAL_INVOCATIONS invocations of $UNIQUE_COMMANDS unique commands." >&2

# ---- Step 2: classify each command ----
echo "  Classifying commands..." >&2

CMDS_NDJSON=$(mktemp)
BUILTINS_FILE=$(mktemp)
UNRESOLVED_TSV=$(mktemp)
trap 'rm -f "$FREQ_TSV" "$SKIP_PATH_TSV" "$CMDS_NDJSON" "$BUILTINS_FILE" "$UNRESOLVED_TSV"' EXIT

classify_command() {
    local cmd="$1"
    local count="$2"

    # Use bash builtin `type -t` to identify shell builtins/keywords/aliases
    local kind
    kind=$(type -t -- "$cmd" 2>/dev/null || echo "")

    case "$kind" in
        builtin|keyword|alias|function)
            echo "$kind:$cmd" >> "$BUILTINS_FILE"
            return
            ;;
    esac

    # Resolve to a real path
    local path
    path=$(command -v -- "$cmd" 2>/dev/null || echo "")
    if [[ -z "$path" ]]; then
        # Either an uninstalled tool OR parser noise (JSON fragments, etc.).
        # Stash separately so it doesn't pollute the main commands list.
        echo "$count	$cmd" >> "$UNRESOLVED_TSV"
        return
    fi

    # Resolve symlinks to find the canonical target
    local real_path
    real_path=$(readlink -f "$path" 2>/dev/null || echo "$path")

    local install_type="other"
    local formula=""

    case "$real_path" in
        /opt/homebrew/Cellar/*|/usr/local/Cellar/*)
            install_type="brew"
            # Extract formula name from .../Cellar/<formula>/<version>/...
            formula=$(awk -F'/Cellar/' '{print $2}' <<<"$real_path" | awk -F'/' '{print $1}')
            ;;
        /opt/homebrew/*|/usr/local/Caskroom/*)
            install_type="brew"
            ;;
        /bin/*|/sbin/*|/usr/bin/*|/usr/sbin/*|/System/*)
            install_type="system"
            ;;
        /Applications/*)
            install_type="app-bundled"
            ;;
        *)
            install_type="other"
            ;;
    esac

    jq -nc \
        --arg n "$cmd" --argjson c "$count" --arg p "$path" --arg rp "$real_path" \
        --arg it "$install_type" --arg f "$formula" \
        '{name:$n, count:$c, path:$p, real_path:$rp, install_type:$it,
          formula: ($f | select(length > 0))}' >> "$CMDS_NDJSON"
}

while IFS=$'\t' read -r count cmd; do
    [[ -z "$cmd" ]] && continue
    classify_command "$cmd" "$count"
done < "$FREQ_TSV"

# ---- Step 3: assemble final JSON ----
echo "  Building JSON..." >&2

SKIPPED_BUILTINS_JSON=$(sort -u "$BUILTINS_FILE" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')
SKIPPED_PATHS_JSON=$(sort -rn "$SKIP_PATH_TSV" 2>/dev/null | jq -R -s '
    split("\n") | map(select(length > 0)) | map(split("\t") | {count: (.[0] | tonumber), name: .[1]})
')
UNRESOLVED_JSON=$(sort -rn "$UNRESOLVED_TSV" 2>/dev/null | jq -R -s '
    split("\n") | map(select(length > 0)) | map(split("\t") | {count: (.[0] | tonumber), name: .[1]})
')

# Counts excluding builtins (already not in CMDS_NDJSON)
KEPT_COUNT=$(wc -l <"$CMDS_NDJSON" | tr -d ' ')

jq -n \
    --arg capture_date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg hostname "$(hostname)" \
    --arg user "$USER" \
    --argjson source_files "$HIST_META_JSON" \
    --argjson total_invocations "$TOTAL_INVOCATIONS" \
    --argjson unique_commands "$UNIQUE_COMMANDS" \
    --argjson kept "$KEPT_COUNT" \
    --argjson skipped_builtins "$SKIPPED_BUILTINS_JSON" \
    --argjson skipped_paths "$SKIPPED_PATHS_JSON" \
    --argjson unresolved "$UNRESOLVED_JSON" \
    --slurpfile cmds "$CMDS_NDJSON" \
    '{
      capture_date: $capture_date,
      hostname: $hostname,
      user: $user,
      source_files: $source_files,
      total_invocations: $total_invocations,
      unique_commands: $unique_commands,
      kept_commands: $kept,
      skipped_builtins: $skipped_builtins,
      skipped_relative_paths: $skipped_paths,
      unresolved: $unresolved,
      commands: $cmds | sort_by(-.count)
    }' > "$OUTPUT_FILE"

# ---- Step 4: summary text ----
{
    echo "========================================"
    echo "CLI Usage Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""
    echo "Sources:"
    jq -r '.source_files[] | "  \(.path)  (\(.lines) lines, \(.bytes) bytes)"' "$OUTPUT_FILE"
    echo ""
    printf "Total invocations:  %d\n" "$TOTAL_INVOCATIONS"
    printf "Unique commands:    %d\n" "$UNIQUE_COMMANDS"
    printf "Kept (classified):  %d\n" "$KEPT_COUNT"
    printf "Skipped builtins:   %d\n" "$(jq '.skipped_builtins | length' "$OUTPUT_FILE")"
    printf "Skipped path-cmds:  %d\n" "$(jq '.skipped_relative_paths | length' "$OUTPUT_FILE")"
    printf "Unresolved/noise:   %d\n" "$(jq '.unresolved | length' "$OUTPUT_FILE")"
    echo ""
    echo "Top 30 classified commands:"
    jq -r '.commands[:30][] | [.count, .install_type, (.formula // "-"), .name] | @tsv' "$OUTPUT_FILE" \
        | awk -F'\t' 'BEGIN{printf "%6s  %-10s  %-20s  %s\n", "COUNT", "TYPE", "FORMULA", "NAME"} {printf "%6s  %-10s  %-20s  %s\n", $1, $2, $3, $4}'
} > "$SUMMARY_FILE"

echo "" >&2
echo "CLI usage captured successfully!" >&2
echo "JSON: $OUTPUT_FILE" >&2
echo "Summary: $SUMMARY_FILE" >&2
echo "" >&2
head -45 "$SUMMARY_FILE"
