#!/usr/bin/env bash

ytdl () 
{ 
    VIDEOS_BASE_DIRECTORY=/data/videos
    VIDEO_DOWNLOADER_COMMAND=$(command -v yt-dlp)

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        echo "Error: No URLs provided. Please specify one or more URLs to download."
        return 1
    fi

    # Determine the script name for logging purposes
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        script_name="${FUNCNAME[0]}"  # Sourced: use the function name
    else
        script_path="${0%/*}"  # Not sourced: get the directory part of the path
        if [ -z "${script_path}" ]; then
            script_path="."  # If no directory, use current directory
        fi
        script_name="$(cd "${script_path}" && pwd)/${0##*/}"  # Full path with script name
    fi

    # Process each URL passed as an argument
    while [ -n "$1" ]; do
        URL="$1"  # Get the first argument
        echo "Downloading video from: ${URL}"

        # Extract the domain from the URL for organizing downloads
        DOMAIN=$(echo "${URL}" | awk -F[/:] '{print $4}')
        DOMAIN_VIDEOS_DIRECTORY="${VIDEOS_BASE_DIRECTORY}/${DOMAIN}"

        # Create the video domain subdirectory if it doesn't exist
        [ -d "${DOMAIN_VIDEOS_DIRECTORY}" ] || mkdir -p "${DOMAIN_VIDEOS_DIRECTORY}" || {
            echo "Error: Could not create directory: ${DOMAIN_VIDEOS_DIRECTORY}"
            return 1
        }

        # Set a per-domain log file
        DOMAIN_DOWNLOAD_LOG="${DOMAIN_VIDEOS_DIRECTORY%/}.log"

        (
            cd "${DOMAIN_VIDEOS_DIRECTORY}" || exit 1
            DATESTAMP=$(date "+%Y-%m-%d %H:%M:%S %a")
            printf '[%s] [%s] [%s] %s\n' "${DATESTAMP}" "${script_name}" "${HOSTNAME}" "${URL}" >> "${DOMAIN_DOWNLOAD_LOG}"
            ${VIDEO_DOWNLOADER_COMMAND} "${URL}" || echo "Failed to download: ${URL}"
        )

        shift  # Move to the next argument
    done
}

# Source the footer
source bash_footer.template.live

