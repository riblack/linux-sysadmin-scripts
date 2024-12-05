#!/usr/bin/env bash

cdv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    [ -d "${VIDEOS_BASE_DIRECTORY}" ] || mkdir -p "${VIDEOS_BASE_DIRECTORY}"
    cd "${VIDEOS_BASE_DIRECTORY}"
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

