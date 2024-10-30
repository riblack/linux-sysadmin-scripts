#!/usr/bin/env bash

ytdl () 
{ 
    VIDEO_DIRECTORY=/data/videos
    VIDEO_DOWNLOADER=$(command -v yt-dlp)

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        echo "Error: No URLs provided. Please specify one or more URLs to download."
        return 1
    fi

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

        # Extract the domain from the URL
        DOMAIN=$(echo "${URL}" | awk -F[/:] '{print $4}')
        DOMAIN_DIRECTORY="${VIDEO_DIRECTORY}/${DOMAIN}"

        # Create the video domain subdirectory if it doesn't exist
        [ -d "${DOMAIN_DIRECTORY}" ] || mkdir -p "${DOMAIN_DIRECTORY}"

        # Set a per domain log file
        DOMAIN_DOWNLOAD_LOG="${DOMAIN_DIRECTORY%/}.log"

        (
            cd "${DOMAIN_DIRECTORY}" || exit 1
            DATESTAMP=$(date "+%Y-%m-%d %H:%M:%S %a")
            printf '[%s] [%s] [%s] %s\n' "${DATESTAMP}" "${script_name}" "${HOSTNAME}" "${URL}" >> "${DOMAIN_DOWNLOAD_LOG}"
            ${VIDEO_DOWNLOADER} "${URL}" || echo "Failed to download: ${URL}"
        )

        shift  # Shift the arguments to process the next one
    done

    # Return the name of the function or script
    echo "Called from: ${script_name}"
}

# Source the footer
source bash_footer.template.live

