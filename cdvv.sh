#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

cdvv() {
    VIDEOS_BASE_DIRECTORY="/data/videos"
    LAST_VIDEO_DOWNLOAD_DIRECTORY=$(
        cd "${VIDEOS_BASE_DIRECTORY}"
        ls -tr | tail -n 1
    )
    LAST_VIDEO_DOWNLOAD_DIRECTORY="${VIDEOS_BASE_DIRECTORY}/${LAST_VIDEO_DOWNLOAD_DIRECTORY%.log}"
    [ -d "${LAST_VIDEO_DOWNLOAD_DIRECTORY}" ] && cd "${LAST_VIDEO_DOWNLOAD_DIRECTORY}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
