#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdvv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    LAST_VIDEO_DOWNLOAD_DIRECTORY=$( cd "${VIDEOS_BASE_DIRECTORY}"; ls -tr | tail -n 1 )
    LAST_VIDEO_DOWNLOAD_DIRECTORY="${VIDEOS_BASE_DIRECTORY}/${LAST_VIDEO_DOWNLOAD_DIRECTORY%.log}"
    [ -d "${LAST_VIDEO_DOWNLOAD_DIRECTORY}" ] && cd "${LAST_VIDEO_DOWNLOAD_DIRECTORY}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

