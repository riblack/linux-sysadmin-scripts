#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    [ -d "${VIDEOS_BASE_DIRECTORY}" ] || mkdir -p "${VIDEOS_BASE_DIRECTORY}"
    cd "${VIDEOS_BASE_DIRECTORY}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

