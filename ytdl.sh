#!/bin/bash

ytdl () 
{ 
    VIDEO_DIRECTORY=/data/videos
    VIDEO_DOWNLOAD_URL_LOG="${VIDEO_DIRECTORY}/grab_downloaded_urls.log"
    VIDEO_DOWNLOADER=$(command -v yt-dlp)

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        echo "Error: No URLs provided. Please specify one or more URLs to download."
        return 1
    fi

    # Create the video directory if it doesn't exist
    [ -d "${VIDEO_DIRECTORY}" ] || mkdir -p "${VIDEO_DIRECTORY}"

    # Process each URL passed as an argument
    while [ -n "$1" ]; do
        url="$1"  # Get the first argument
        echo "Downloading video from: $url"
        
        (   
            cd "${VIDEO_DIRECTORY}" || exit 1
            printf '%s %s\n' "$(date "+%Y%m%d_%H%M%S")" "$url" >> "${VIDEO_DOWNLOAD_URL_LOG}"
            ${VIDEO_DOWNLOADER} "$url" || echo "Failed to download: $url"
        )
        
        shift  # Shift the arguments to process the next one
    done
}

