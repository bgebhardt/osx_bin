#!/bin/bash
#
# lib-brewfile-parse.sh
# Sourceable library for looking up entries in a Brewfile (active or tombstone).
#
# Usage:
#   source lib-brewfile-parse.sh
#   BREWFILE=$(find_latest_snapshot_brewfile) || exit 1
#   brewfile_find_cask  "$BREWFILE" "obsidian"
#   brewfile_find_brew  "$BREWFILE" "jq"
#   brewfile_find_mas_by_id   "$BREWFILE" "1569813296"
#   brewfile_find_mas_by_name "$BREWFILE" "1Password for Safari"
#
# Each lookup prints one of:
#   active:<the entire Brewfile line>
#   tombstone:<the entire Brewfile line>
#   (empty — no match)
#
# Tombstones are commented-out entries (`# cask "foo"`), inserted by
# setup/homebrew/generate-brewfiles.py from the source-script journals
# (commented `# brew install foo` lines). They drive state-sync's "promotion"
# feature: a manually-installed app gets auto-listed as `cask "foo"` if its
# tombstone exists in the snapshot.

# Locate the most recent generated snapshot Brewfile.
# Returns 0 + path on stdout if found, 1 otherwise.
# Uses bash glob + stat to avoid an `ls` alias (the user's shell aliases ls=eza).
find_latest_snapshot_brewfile() {
    local home_dir="${HOMEBREW_SETUP_DIR:-$HOME/bin/setup/homebrew}"
    local -a candidates=()
    local f
    shopt -s nullglob
    for f in "$home_dir"/Brewfile.*.20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]; do
        candidates+=("$f")
    done
    shopt -u nullglob
    local newest="" newest_mtime=0 mtime
    for f in "${candidates[@]}"; do
        mtime=$(stat -f "%m" "$f" 2>/dev/null || stat -c "%Y" "$f" 2>/dev/null)
        if [[ -n "$mtime" ]] && (( mtime > newest_mtime )); then
            newest_mtime=$mtime
            newest=$f
        fi
    done
    if [[ -n "$newest" ]]; then
        printf '%s\n' "$newest"
        return 0
    fi
    # Fall back to master Brewfile if no snapshot exists.
    if [[ -f "$home_dir/Brewfile" ]]; then
        printf '%s\n' "$home_dir/Brewfile"
        return 0
    fi
    return 1
}

# Internal: print `active:<line>` if grep finds the pattern as a live entry,
# `tombstone:<line>` if it finds it as a commented entry, else nothing.
# $1 = Brewfile path, $2 = active-entry regex, $3 = tombstone regex.
_brewfile_lookup() {
    local brewfile="$1" active_re="$2" tomb_re="$3" line
    line=$(grep -m1 -E "$active_re" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'active:%s\n' "$line"
        return 0
    fi
    line=$(grep -m1 -E "$tomb_re" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'tombstone:%s\n' "$line"
        return 0
    fi
    return 1
}

# Escape a string for use as a literal inside an extended regex (grep -E).
_brewfile_re_escape() {
    printf '%s' "$1" | sed -E 's/[][\\.^$*+?(){}|/]/\\&/g'
}

# Look up a cask by name. Matches both the bare short name (`obsidian`) and
# a tap-qualified path (`caskroom/cask/kdiff3`).
brewfile_find_cask() {
    local brewfile="$1" name="$2" esc
    esc=$(_brewfile_re_escape "$name")
    _brewfile_lookup "$brewfile" \
        "^cask \"([^\"]*\/)?${esc}\"" \
        "^# cask \"([^\"]*\/)?${esc}\""
}

# Look up a brew formula by name. Same tap-qualified matching.
brewfile_find_brew() {
    local brewfile="$1" name="$2" esc
    esc=$(_brewfile_re_escape "$name")
    _brewfile_lookup "$brewfile" \
        "^brew \"([^\"]*\/)?${esc}\"" \
        "^# brew \"([^\"]*\/)?${esc}\""
}

# Look up a Mac App Store entry by numeric ID.
brewfile_find_mas_by_id() {
    local brewfile="$1" id="$2" esc
    esc=$(_brewfile_re_escape "$id")
    _brewfile_lookup "$brewfile" \
        "^mas \"[^\"]+\", id: ${esc}([^0-9]|$)" \
        "^# mas \"[^\"]+\", id: ${esc}([^0-9]|$)"
}

# Look up a Mac App Store entry by display name (case-insensitive).
brewfile_find_mas_by_name() {
    local brewfile="$1" name="$2" esc line
    esc=$(_brewfile_re_escape "$name")
    line=$(grep -m1 -iE "^mas \"${esc}\", id:" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'active:%s\n' "$line"
        return 0
    fi
    line=$(grep -m1 -iE "^# mas \"${esc}\", id:" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'tombstone:%s\n' "$line"
        return 0
    fi
    return 1
}

# Look up a tap entry. Matches the user/repo form, case-insensitive.
brewfile_find_tap() {
    local brewfile="$1" name="$2" esc
    esc=$(_brewfile_re_escape "$name")
    local line
    line=$(grep -m1 -iE "^tap \"${esc}\"" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'active:%s\n' "$line"
        return 0
    fi
    line=$(grep -m1 -iE "^# tap \"${esc}\"" "$brewfile" 2>/dev/null || true)
    if [[ -n "$line" ]]; then
        printf 'tombstone:%s\n' "$line"
        return 0
    fi
    return 1
}
