#!/usr/bin/env bash

# hotkeys-cheat-sheet.sh - Generate a markdown cheat sheet for Obsidian hotkeys.

# Usage: ./hotkeys-cheat-sheet.sh hotkeys.json > cheat-sheet.md

input_json="$1"

if [[ -z "$input_json" ]]; then
    echo "Usage: $0 <hotkeys.json>" >&2
    exit 1
fi

# Original copilot try that didn't work.

# jq -r '
#     to_entries[] |
#     {
#         command: .key,
#         hotkeys: .value
#     } |
#     select(.hotkeys | length > 0) |
#     .hotkeys[] |
#     [
#         .modifiers // [],
#         .key
#     ] |
#     "\(.[0] | join(\"+\") )+\(.[1])"
#     as $combo
#     |
#     .command as $cmd
#     |
#     [$cmd, $combo]
# ' "$input_json" |
# awk '
#     BEGIN {
#         print "| Command | Hotkey |"
#         print "|---------|--------|"
#     }
#     NR % 2 == 1 { cmd = $0 }
#     NR % 2 == 0 { print "| " cmd " | " $0 " |" }
'

# How I built up to the final jq query.

# # List all commands in the JSON file
# jq -r 'keys[]' "$input_json"

# # Get the modifiers and key for the first command in the JSON file
# jq -r 'to_entries[0].value[0] | {modifiers, key}' "$input_json"

# # Pull the key, modifiers, and value.key from the first entry
# jq -r 'to_entries[1] | {key: .key, modifiers: .value[0].modifiers, value_key: .value[0].key}' "$input_json"

# # Flatten the modifiers into a string for to_entries[1]
# jq -r '
#     to_entries[1] |
#     {
#         command: .key,
#         modifiers: (.value[0].modifiers // [] | join("+")),
#         key: .value[0].key
#     }
# ' "$input_json"

# List all commands and their modifiers
hotkeys_list=$(jq -r '
    to_entries[] |
    select(.value | length > 0) |
    {
        command: .key,
        modifiers: (.value[0].modifiers // [] | join("+")),
        key: .value[0].key
    }
' "$input_json")

# Print out hotkeys in a markdown table format
echo "| Command | Modifiers | Key |"
echo "|---------|-----------|-----|"
echo "$hotkeys_list" | jq -r '    
    ( . | [.command, .modifiers, .key] )
    | @tsv
' | tail -n +3 | awk -F'\t' '{ printf "| %s | %s | %s |\n", $1, $2, $3 }'

# Sample snippet from hotkeys.json file in .obsidian directory
# {
#   "editor:toggle-checklist-status": [],
#   "url-into-selection:paste-url-into-selection": [
#     {
#       "modifiers": [
#         "Ctrl",
#         "Mod"
#       ],
#       "key": "V"
#     }
#   ],
#   "periodic-notes:open-weekly-note": [
#     {
#       "modifiers": [
#         "Alt",
#         "Mod"
#       ],
#       "key": "W"
#     }
#   ],
#   "obsidian-tasks-plugin:toggle-done": [
#     {
#       "modifiers": [
#         "Ctrl"
#       ],
#       "key": "L"
#     }
#   ],