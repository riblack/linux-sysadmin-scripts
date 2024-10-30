#!/usr/bin/env bash

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

    # Determine the name to return
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        # Sourced: use the function name
        script_name="${FUNCNAME[0]}"
    else
        # Not sourced: get the full path
        script_path="${0%/*}"  # Get the directory part of the path
        if [[ -z "${script_path}" ]]; then
            script_path="."  # If no directory, use current directory
        fi
        script_name="$(cd "${script_path}" && pwd)/${0##*/}"  # Full path with script name
    fi

    # Process each URL passed as an argument
    while [ -n "$1" ]; do
        URL="$1"  # Get the first argument
        echo "Downloading video from: ${URL}"
        
        (   
            cd "${VIDEO_DIRECTORY}" || exit 1
            DATESTAMP=$(date "+%Y-%m-%d %H:%M:%S %a")
            printf '[%s] [%s] [%s] %s\n' "${DATESTAMP}" "${script_name}" "${HOSTNAME}" "${URL}" >> "${VIDEO_DOWNLOAD_URL_LOG}"
            ${VIDEO_DOWNLOADER} "${URL}" || echo "Failed to download: ${URL}"
        )
        
        shift  # Shift the arguments to process the next one
    done

    # Return the name of the function or script
    echo "Called from: ${script_name}"
}

# Source the footer
source bash_footer.template.live

