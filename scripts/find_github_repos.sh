#!/bin/bash

# Script to find all GitHub repositories in the current directory and below
# Prints the parent directory path of each GitHub repository found

# Find all .git directories recursively
find . -type d -name ".git" -print0 | while IFS= read -r -d '' git_dir; do
    # Get the parent directory of the .git folder
    repo_dir="$(dirname "$git_dir")"
    
    # Check if any remote URL contains 'github.com'
    if git --git-dir="$git_dir" config --get-regexp '^remote\..*\.url$' | grep -q 'github\.com'; then
        # Print the absolute path of the repository
        echo "Found GitHub repo: $(cd "$repo_dir" && pwd)"
    fi
done

