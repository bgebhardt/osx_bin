#!/opt/homebrew/bin/bash

# Script to determine if each application in /Applications is installed by brew, mas, or other means
# Requires bash 4.0+ for associative arrays
#
# Usage: apps-by-install-type.sh [OPTIONS]
# OPTIONS:
#   -h, --help     Show this help message

# Usage function
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Determine installation source (brew, mas, or other) for each app in /Applications

OPTIONS:
    -h, --help            Show this help message
    -d, --debug-lists     Write mas and brew app lists to files for debugging
                          (mas-apps-debug.txt and brew-apps-debug.txt)

OUTPUT FORMAT:
    <install_type> # <app_name>

EXAMPLES:
    mas    # 1Password for Safari
    brew   # Aerial
    other  # MyCustomApp
EOF
    exit 0
}

# Parse command line options
debug_lists=false
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_usage
            ;;
        -d|--debug-lists)
            debug_lists=true
            ;;
    esac
done

echo "Building list of mas-installed apps..." >&2

# Build associative array of mas-installed apps
# Key: lowercase app name (extracted from mas list output), Value: "mas"
declare -A mas_apps

while IFS= read -r line; do
    # Extract app name from mas list output (text between number and version)
    # Format: "1569813296  1Password for Safari            (8.11.22)"
    # Use awk to extract fields between the ID and the version in parentheses
    app_name=$(echo "$line" | awk '{$1=""; sub(/^[ \t]+/, ""); sub(/[ \t]+\([^)]+\)[ \t]*$/, ""); print}')

    if [[ -n "$app_name" ]]; then
        # Convert to lowercase for comparison
        app_name_lower="${app_name,,}"
        mas_apps["$app_name_lower"]="mas"
    fi
done < <(mas list 2>/dev/null)

# Write mas apps to debug file if requested
if [[ "$debug_lists" == true ]]; then
    echo "Writing mas apps to mas-apps-debug.txt..." >&2
    true > mas-apps-debug.txt
    for app in "${!mas_apps[@]}"; do
        echo "$app" >> mas-apps-debug.txt
    done
    sort -o mas-apps-debug.txt mas-apps-debug.txt
fi

echo "Building list of brew-installed apps..." >&2

# Build associative array of brew-installed apps
# Key: lowercase app name (from Artifacts section), Value: "brew"
declare -A brew_apps

# Get list of all casks and process them more efficiently
# Instead of calling brew info for each, we'll look in the Caskroom directory
while IFS= read -r cask_line; do
    # Extract just the cask name (first field)
    cask_name=$(echo "$cask_line" | awk '{print $1}')

    # Try to find the app in common brew cask installation locations
    for cask_root in /opt/homebrew/Caskroom /usr/local/Caskroom; do
        if [[ -d "$cask_root/$cask_name" ]]; then
            # Look for .app or .saver files in the cask directory
            while IFS= read -r app_file; do
                if [[ -n "$app_file" ]]; then
                    app=$(basename "$app_file")
                    if [[ "$app" =~ \.app$ ]]; then
                        app_name="${app%.app}"
                    elif [[ "$app" =~ \.saver$ ]]; then
                        app_name="${app%.saver}"
                    else
                        continue
                    fi
                    app_name_lower="${app_name,,}"
                    brew_apps["$app_name_lower"]="brew"
                fi
            done < <(find "$cask_root/$cask_name" -maxdepth 3 \( -name "*.app" -o -name "*.saver" \) 2>/dev/null)
            break
        fi
    done
done < <(brew list --cask 2>/dev/null)

# Write brew apps to debug file if requested
if [[ "$debug_lists" == true ]]; then
    echo "Writing brew apps to brew-apps-debug.txt..." >&2
    true > brew-apps-debug.txt
    for app in "${!brew_apps[@]}"; do
        echo "$app" >> brew-apps-debug.txt
    done
    sort -o brew-apps-debug.txt brew-apps-debug.txt
fi

echo "Checking applications in /Applications..." >&2
echo "" >&2

# Now iterate through all apps in /Applications
for app_path in /Applications/*.app; do
    # Skip if no .app files found
    [[ -e "$app_path" ]] || continue

    # Get just the filename and remove .app extension
    app=$(basename "$app_path")
    app_name="${app%.app}"
    app_name_lower="${app_name,,}"

    # Check if installed by mas or brew
    if [[ -n "${mas_apps[$app_name_lower]}" ]]; then
        echo "mas    # $app_name"
    elif [[ -n "${brew_apps[$app_name_lower]}" ]]; then
        echo "brew   # $app_name"
    else
        echo "other  # $app_name"
    fi
done
