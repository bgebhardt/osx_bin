#!/bin/bash
#
# lib-classify-app.sh
# Sourceable library that builds an index mapping app names to install metadata
# (install_type, mas_id, cask_name, version).
#
# Usage:
#   source lib-classify-app.sh
#   classify_app_init                  # builds index, sets $CLASSIFY_INDEX
#   ... use $CLASSIFY_INDEX (path to JSON) ...
#   classify_app_cleanup               # removes temp index
#
# Index JSON format (keyed by lowercase app name):
#   {
#     "obsidian":              {"install_type": "brew", "cask_name": "obsidian"},
#     "1password for safari":  {"install_type": "mas",  "mas_id": "1569813296"},
#     ...
#   }

CLASSIFY_INDEX=""

classify_app_init() {
    if ! command -v jq &>/dev/null; then
        echo "lib-classify-app: jq required" >&2
        return 1
    fi

    CLASSIFY_INDEX=$(mktemp)
    local mas_ndjson brew_ndjson
    mas_ndjson=$(mktemp)
    brew_ndjson=$(mktemp)

    if command -v mas &>/dev/null; then
        mas list 2>/dev/null | while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local id name
            id=$(awk '{print $1}' <<<"$line")
            name=$(awk '{$1=""; sub(/^[ \t]+/, ""); sub(/[ \t]+\([^)]+\)[ \t]*$/, ""); print}' <<<"$line")
            [[ -z "$name" ]] && continue
            jq -nc --arg name "$name" --arg id "$id" \
                '{key: ($name | ascii_downcase), value: {install_type: "mas", mas_id: $id, name: $name}}'
        done > "$mas_ndjson"
    fi

    if command -v brew &>/dev/null; then
        while IFS= read -r cask_name; do
            [[ -z "$cask_name" ]] && continue
            for cask_root in /opt/homebrew/Caskroom /usr/local/Caskroom; do
                if [[ -d "$cask_root/$cask_name" ]]; then
                    while IFS= read -r app_file; do
                        [[ -z "$app_file" ]] && continue
                        local app app_name
                        app=$(basename "$app_file")
                        if [[ "$app" == *.app ]]; then
                            app_name="${app%.app}"
                        elif [[ "$app" == *.saver ]]; then
                            app_name="${app%.saver}"
                        else
                            continue
                        fi
                        jq -nc --arg name "$app_name" --arg cask "$cask_name" \
                            '{key: ($name | ascii_downcase), value: {install_type: "brew", cask_name: $cask, name: $name}}'
                    done < <(find "$cask_root/$cask_name" -maxdepth 3 \( -name "*.app" -o -name "*.saver" \) 2>/dev/null)
                    break
                fi
            done
        done < <(brew list --cask 2>/dev/null) > "$brew_ndjson"
    fi

    # Merge into single map; brew wins if there's an unlikely collision
    jq -n --slurpfile mas <(cat "$mas_ndjson" | jq -s '.') \
          --slurpfile brew <(cat "$brew_ndjson" | jq -s '.') \
          '(($mas[0] // []) + ($brew[0] // []))
           | map({(.key): .value})
           | add // {}' > "$CLASSIFY_INDEX"

    rm -f "$mas_ndjson" "$brew_ndjson"
    export CLASSIFY_INDEX
}

classify_app_cleanup() {
    [[ -n "$CLASSIFY_INDEX" && -f "$CLASSIFY_INDEX" ]] && rm -f "$CLASSIFY_INDEX"
    CLASSIFY_INDEX=""
}
