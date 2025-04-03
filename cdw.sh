#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdw() {
    WORKSPACE_DIR="${HOME}/workspace"
    [ -d "$WORKSPACE_DIR" ] || mkdir -p "$WORKSPACE_DIR"

    # Find latest subdirectory (not files), sorted by mtime
    latest_subdir=$(find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)

    if [[ -n "$latest_subdir" ]]; then
        cd "$latest_subdir" || return
    else
        cd "$WORKSPACE_DIR" || return
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi
