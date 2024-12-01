#!/usr/bin/env bash

cdvv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    LAST_VIDEO_DOWNLOAD_DIRECTORY=$( cd "${VIDEOS_BASE_DIRECTORY}"; ls -tr | tail -n 1 )
    LAST_VIDEO_DOWNLOAD_DIRECTORY="${VIDEOS_BASE_DIRECTORY}/${LAST_VIDEO_DOWNLOAD_DIRECTORY%.log}"
    [ -d "${LAST_VIDEO_DOWNLOAD_DIRECTORY}" ] && cd "${LAST_VIDEO_DOWNLOAD_DIRECTORY}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

