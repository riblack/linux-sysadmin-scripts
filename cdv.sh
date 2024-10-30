#!/usr/bin/env bash

cdv () 
{ 
    VIDEOS_BASE_DIRECTORY="/data/videos"
    [ -d "${VIDEOS_BASE_DIRECTORY}" ] || mkdir -p "${VIDEOS_BASE_DIRECTORY}"
    cd "${VIDEOS_BASE_DIRECTORY}"
}

# Source the footer
source bash_footer.template.live

