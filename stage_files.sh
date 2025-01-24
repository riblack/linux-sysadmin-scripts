#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to stage files
stage_files ()
{
    local files=("$@")
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files specified. Checking for already staged files..."
        if ! git diff --cached --quiet; then
            echo "Files already staged for commit:"
            git diff --cached --name-only
            return 0
        else
            echo "Error: No files staged for commit and none specified."
            exit 1
        fi
    fi

    echo "Staging the following files:"
    printf "  %s\n" "${files[@]}"
    git add -- "${files[@]}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

