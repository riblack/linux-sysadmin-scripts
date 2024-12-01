#!/usr/bin/env bash

cdv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    [ -d "${VIDEOS_BASE_DIRECTORY}" ] || mkdir -p "${VIDEOS_BASE_DIRECTORY}"
    cd "${VIDEOS_BASE_DIRECTORY}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

