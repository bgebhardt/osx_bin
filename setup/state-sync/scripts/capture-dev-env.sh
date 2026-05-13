#!/bin/bash
#
# capture-dev-env.sh
# Captures development environment state
#
# Output: Versions of tools, paths, environment variables
# Usage: ./capture-dev-env.sh [output_dir]

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# Default output directory (use config if no argument provided)
if [[ -n "${1:-}" ]]; then
    OUTPUT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    OUTPUT_DIR="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
fi
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/dev-env.json"
SUMMARY_FILE="$OUTPUT_DIR/dev-env.txt"

echo "Capturing development environment state..."
echo "Output directory: $OUTPUT_DIR"

# Helper function to get version
get_version() {
    local cmd="$1"
    local version_arg="${2:---version}"
    if command -v "$cmd" &> /dev/null; then
        "$cmd" "$version_arg" 2>&1 | head -1 || echo "installed (version unknown)"
    else
        echo "not installed"
    fi
}

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"

# Programming languages
echo "  \"languages\": {" >> "$OUTPUT_FILE"
echo "    \"python\": \"$(get_version python3)\"," >> "$OUTPUT_FILE"
echo "    \"python2\": \"$(get_version python)\"," >> "$OUTPUT_FILE"
echo "    \"node\": \"$(get_version node)\"," >> "$OUTPUT_FILE"
echo "    \"npm\": \"$(get_version npm)\"," >> "$OUTPUT_FILE"
echo "    \"ruby\": \"$(get_version ruby)\"," >> "$OUTPUT_FILE"
echo "    \"go\": \"$(get_version go version)\"," >> "$OUTPUT_FILE"
echo "    \"rust\": \"$(get_version rustc)\"," >> "$OUTPUT_FILE"
echo "    \"java\": \"$(get_version java)\"," >> "$OUTPUT_FILE"
echo "    \"php\": \"$(get_version php)\"," >> "$OUTPUT_FILE"
echo "    \"perl\": \"$(get_version perl)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Version managers
echo "  \"version_managers\": {" >> "$OUTPUT_FILE"
echo "    \"nvm\": \"$([ -d "$HOME/.nvm" ] && echo 'installed' || echo 'not installed')\"," >> "$OUTPUT_FILE"
echo "    \"pyenv\": \"$(get_version pyenv)\"," >> "$OUTPUT_FILE"
echo "    \"rbenv\": \"$(get_version rbenv)\"," >> "$OUTPUT_FILE"
echo "    \"rvm\": \"$(get_version rvm)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Package managers
echo "  \"package_managers\": {" >> "$OUTPUT_FILE"
echo "    \"pip\": \"$(get_version pip3)\"," >> "$OUTPUT_FILE"
echo "    \"pip2\": \"$(get_version pip)\"," >> "$OUTPUT_FILE"
echo "    \"yarn\": \"$(get_version yarn)\"," >> "$OUTPUT_FILE"
echo "    \"pnpm\": \"$(get_version pnpm)\"," >> "$OUTPUT_FILE"
echo "    \"gem\": \"$(get_version gem)\"," >> "$OUTPUT_FILE"
echo "    \"cargo\": \"$(get_version cargo)\"," >> "$OUTPUT_FILE"
echo "    \"composer\": \"$(get_version composer)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Development tools
echo "  \"dev_tools\": {" >> "$OUTPUT_FILE"
echo "    \"git\": \"$(get_version git)\"," >> "$OUTPUT_FILE"
echo "    \"docker\": \"$(get_version docker)\"," >> "$OUTPUT_FILE"
echo "    \"docker-compose\": \"$(get_version docker-compose)\"," >> "$OUTPUT_FILE"
echo "    \"kubectl\": \"$(get_version kubectl version --client --short 2>&1 | head -1 || echo 'not installed')\"," >> "$OUTPUT_FILE"
echo "    \"terraform\": \"$(get_version terraform)\"," >> "$OUTPUT_FILE"
echo "    \"vagrant\": \"$(get_version vagrant)\"," >> "$OUTPUT_FILE"
echo "    \"make\": \"$(get_version make)\"," >> "$OUTPUT_FILE"
echo "    \"cmake\": \"$(get_version cmake)\"," >> "$OUTPUT_FILE"
echo "    \"gcc\": \"$(get_version gcc)\"," >> "$OUTPUT_FILE"
echo "    \"clang\": \"$(get_version clang)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Git configuration (safe parts only)
echo "  \"git_config\": {" >> "$OUTPUT_FILE"
GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "not set")
GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "not set")
GIT_DEFAULT_BRANCH=$(git config --global init.defaultBranch 2>/dev/null || echo "not set")
echo "    \"user_name\": \"$GIT_USER_NAME\"," >> "$OUTPUT_FILE"
echo "    \"user_email\": \"$GIT_USER_EMAIL\"," >> "$OUTPUT_FILE"
echo "    \"default_branch\": \"$GIT_DEFAULT_BRANCH\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# SSH keys (names only, not content)
echo "  \"ssh_keys\": [" >> "$OUTPUT_FILE"
if [[ -d "$HOME/.ssh" ]]; then
    first=true
    while IFS= read -r keyfile; do
        [[ -z "$keyfile" ]] && continue
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi
        echo -n "    \"$(basename "$keyfile")\"" >> "$OUTPUT_FILE"
    done < <(find "$HOME/.ssh" -name "*.pub" -type f 2>/dev/null | sort)
    echo "" >> "$OUTPUT_FILE"
fi
echo "  ]," >> "$OUTPUT_FILE"

# Environment variables (safe ones)
echo "  \"environment\": {" >> "$OUTPUT_FILE"
echo "    \"SHELL\": \"$SHELL\"," >> "$OUTPUT_FILE"
echo "    \"PATH\": \"$PATH\"," >> "$OUTPUT_FILE"
echo "    \"EDITOR\": \"${EDITOR:-not set}\"," >> "$OUTPUT_FILE"
echo "    \"LANG\": \"${LANG:-not set}\"," >> "$OUTPUT_FILE"
echo "    \"HOME\": \"$HOME\"" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"

echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "Development Environment Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""

    echo "========================================"
    echo "Programming Languages"
    echo "========================================"
    echo "Python 3: $(get_version python3)"
    echo "Node.js: $(get_version node)"
    echo "Ruby: $(get_version ruby)"
    echo "Go: $(get_version go version)"
    echo "Rust: $(get_version rustc)"
    echo "Java: $(get_version java)"
    echo ""

    echo "========================================"
    echo "Version Managers"
    echo "========================================"
    echo "NVM: $([ -d "$HOME/.nvm" ] && echo 'installed' || echo 'not installed')"
    echo "pyenv: $(get_version pyenv)"
    echo "rbenv: $(get_version rbenv)"
    echo ""

    echo "========================================"
    echo "Development Tools"
    echo "========================================"
    echo "Git: $(get_version git)"
    echo "Docker: $(get_version docker)"
    echo "Docker Compose: $(get_version docker-compose)"
    echo ""

    echo "========================================"
    echo "Git Configuration"
    echo "========================================"
    echo "User Name: $GIT_USER_NAME"
    echo "User Email: $GIT_USER_EMAIL"
    echo "Default Branch: $GIT_DEFAULT_BRANCH"
    echo ""

    echo "========================================"
    echo "SSH Public Keys"
    echo "========================================"
    if [[ -d "$HOME/.ssh" ]]; then
        find "$HOME/.ssh" -name "*.pub" -type f 2>/dev/null | while read -r keyfile; do
            echo "  $(basename "$keyfile")"
        done
    else
        echo "  (none found)"
    fi
} > "$SUMMARY_FILE"

echo ""
echo "Development environment captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -40 "$SUMMARY_FILE"
