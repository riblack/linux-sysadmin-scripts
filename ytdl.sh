#!/usr/bin/env bash

ytdl () 
{ 
    VIDEOS_BASE_DIRECTORY=/data/videos
    VIDEO_DOWNLOADER_COMMAND=$(command -v yt-dlp)

    # Possible ffmpeg loglevels are numbers or:
    # -v quiet
    # -v panic
    # -v fatal
    # -v error
    # -v warning
    # -v info
    # -v verbose	sufficient enough to catch -bitextract
    # -v debug
    # -v trace

    VIDEO_DOWNLOADER_COMMAND_ARGS=()
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--mtime")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader" "http:ffmpeg")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("-k" "--format" "mp4")

# -x -k --audio-format mp3 --audio-quality 192K --format mp4 
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("-x" "--audio-format" "mp3" "--audio-quality" "192K")

    #VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-all-thumbnails" "--convert-thumbnails" "png")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-all-thumbnails")

    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-subs" "--write-auto-subs" "--sub-format" "vtt/srt/ass/best" "--sub-langs" "en,es,en.*,es.*,eo,epo,eo.*,epo.*")

    # You must enable the above --downloader http:ffmpeg in order to use the following
    # You must put all ffmpeg arguments into one line (else the last ffmpeg args wins)
    # So, choose either one of the following, do not choose multiples:

    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-bitexact") 			# ffmpeg -bitexact without verbose
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v verbose -bitexact")	# ffmpeg -bitexact with verbose
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v debug -bitexact")	# ffmpeg -bitexact with debug
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v trace -bitexact")	# ffmpeg -bitexact with debug

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

        # Extract a usable video handle for use in finding this content after downloads complete
        case "${URL}" in
            *youtube.com/shorts/*)
                VIDEO_HANDLE="[${URL##*/}]"
                echo "This is a youtube short, the id is the last field: ${VIDEO_HANDLE}" 1>&2
            ;;
            *youtube.com/watch?v=*)
                VIDEO_HANDLE="[${URL##*/}]"
                VIDEO_HANDLE=$(echo "${VIDEO_HANDLE}" | sed -e 's,watch?v=,,' -e 's,&.*$,,')
                echo "This is a regular youtube video, we picked out this as the video handle: ${VIDEO_HANDLE}" 1>&2
            ;;
            *)
                VIDEO_HANDLE="[${URL##*/}]"
                echo "No specific video handler built for this type of url so attempting to use last URL field: ${VIDEO_HANDLE}" 1>&2
            ;;
        esac

        (
            cd "${DOMAIN_VIDEOS_DIRECTORY}" || exit 1
            DATESTAMP_NOW=$(date "+%Y-%m-%d %H:%M:%S %a")

            # Add entry to the logfile
            printf '[%s] [%s] [%s] %s\n' "${DATESTAMP_NOW}" "${script_name}" "${HOSTNAME}" "${URL}" >> "${DOMAIN_DOWNLOAD_LOG}"

            # Perform the downloads for this single URL
            ${VIDEO_DOWNLOADER_COMMAND} "${VIDEO_DOWNLOADER_COMMAND_ARGS[@]}" "${URL}" || echo "Failed to download: ${URL}"

            # Get the earliest datestamp for this particular VIDEO_HANLE
            FILE_DATESTAMP_EARLIEST=$(find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -printf "%T@ %p\n" | sort -n | head -n 1)
            FILE_DATESTAMP_EARLIEST="${FILE_DATESTAMP_EARLIEST%% *}"

            # Apply this timestamp to all files with this VIDEO_HANDLE - this code is optional and is standalone
            find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -exec touch -d "@${FILE_DATESTAMP_EARLIEST}" {} \;

            # Move video files
            VIDEOS_DIRECTORY=videos
            VIDEOS_WORD=videos
            mkdir -p "${VIDEOS_DIRECTORY}"

            VIDEOS_FILE_EXTENSIONS=$(cat <<'EOF'
.mp4
EOF
            )

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${VIDEOS_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_VIDEOS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )
            eval $FIND_VIDEOS_COMMAND | tr '\n' '\0' | xargs -0 -r -I{} mv -v "{}" "${VIDEOS_DIRECTORY}"

            # Move audio files
            AUDIOS_DIRECTORY=audios
            AUDIOS_WORD=audios
            mkdir -p "${AUDIOS_DIRECTORY}"

            AUDIOS_FILE_EXTENSIONS=$(cat <<'EOF'
.mp3
EOF
            )

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${AUDIOS_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_AUDIOS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )
            eval $FIND_AUDIOS_COMMAND | tr '\n' '\0' | xargs -0 -r -I{} mv -v "{}" "${AUDIOS_DIRECTORY}"

            # Archiving thumbnails
            THUMBNAILS_DIRECTORY=thumbnails
            THUMBNAILS_WORD=thumbnails
            mkdir -p "${THUMBNAILS_DIRECTORY}"

            THUMBNAIL_FILE_EXTENSIONS=$(cat <<'EOF'
.jpg
.jpeg
.png
.webp
EOF
            )

            THUMBNAILS_ARCHIVE_FILE="${VIDEO_HANDLE}_$(date -d "@${FILE_DATESTAMP_EARLIEST}" "+%Y%m%d_%H%M%S")_${THUMBNAILS_WORD}.tgz"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${THUMBNAIL_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_THUMBNAILS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )

            # Store the result of the find command
            THUMBNAIL_FILES=$(eval "${FIND_THUMBNAILS_COMMAND}")

            # Check if there are any thumbnail files to process
            if [ -n "$THUMBNAIL_FILES" ]; then
                # Create the tar file if there are thumbnail files
                echo "$THUMBNAIL_FILES" | tr '\n' '\0' | tar --null -T - -czvf "${THUMBNAILS_DIRECTORY}/${THUMBNAILS_ARCHIVE_FILE}"
                touch -d "@${FILE_DATESTAMP_EARLIEST}" "${THUMBNAILS_DIRECTORY}/${THUMBNAILS_ARCHIVE_FILE}"
                echo "$THUMBNAIL_FILES" | tr '\n' '\0' | xargs -0 -r -I{} rm -v "{}"
            else
                echo "No thumbnail files found for processing."
            fi

            # Archiving subtitles
            SUBTITLES_DIRECTORY=subtitles
            SUBTITLES_WORD=subtitles
            mkdir -p "${SUBTITLES_DIRECTORY}"

            SUBTITLE_FILE_EXTENSIONS=$(cat <<'EOF'
.vtt
.srt
.ass
.lrc
EOF
            )

            SUBTITLES_ARCHIVE_FILE="${VIDEO_HANDLE}_$(date -d "@${FILE_DATESTAMP_EARLIEST}" "+%Y%m%d_%H%M%S")_${SUBTITLES_WORD}.tgz"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${SUBTITLE_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_SUBTITLES_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*${VIDEO_HANDLE}*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )

            # Store the result of the find command
            SUBTITLE_FILES=$(eval "${FIND_SUBTITLES_COMMAND}")

            # Check if there are any subtitle files to process
            if [ -n "$SUBTITLE_FILES" ]; then
                # Create the tar file if there are subtitle files
                echo "$SUBTITLE_FILES" | tr '\n' '\0' | tar --null -T - -czvf "${SUBTITLES_DIRECTORY}/${SUBTITLES_ARCHIVE_FILE}"
                touch -d "@${FILE_DATESTAMP_EARLIEST}" "${SUBTITLES_DIRECTORY}/${SUBTITLES_ARCHIVE_FILE}"
                echo "$SUBTITLE_FILES" | tr '\n' '\0' | xargs -0 -r -I{} rm "{}"
            else
                echo "No subtitle files found for processing."
            fi

        )

        shift  # Move to the next argument
    done
}

# Source the footer
source bash_footer.template.live

