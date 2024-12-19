#!/usr/bin/env bash
echo working on ytdl-improvements

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("-k")

    # -x -k --audio-format mp3 --audio-quality 192K --format mp4
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("-x")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--audio-format" "mp3" "--audio-quality" "192K")

    # Video and Audio
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--format" "mp4")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--format" "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best")

    #VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-all-thumbnails" "--convert-thumbnails" "png")
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-all-thumbnails")

    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--write-subs" "--write-auto-subs" "--sub-format" "vtt/srt/ass/best" "--sub-langs" "en,es,en.*,es.*,eo,epo,eo.*,epo.*")

    # You must enable the above --downloader http:ffmpeg in order to use the following
    # You must put all ffmpeg arguments into one line (else the last ffmpeg args wins)
    # So, choose either one of the following, do not choose multiples:

    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-bitexact") 		# ffmpeg -bitexact without verbose
    VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v verbose -bitexact")	# ffmpeg -bitexact with verbose
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v debug -bitexact")	# ffmpeg -bitexact with debug
    # VIDEO_DOWNLOADER_COMMAND_ARGS+=("--downloader-args" "ffmpeg:-v trace -bitexact")	# ffmpeg -bitexact with debug

            VIDEOS_FILE_EXTENSIONS=$(cat <<'EOF'
.mp4
EOF
            )

            AUDIOS_FILE_EXTENSIONS=$(cat <<'EOF'
.mp3
.m4a
EOF
            )

            THUMBNAIL_FILE_EXTENSIONS=$(cat <<'EOF'
.jpg
.jpeg
.png
.webp
EOF
            )

            SUBTITLE_FILE_EXTENSIONS=$(cat <<'EOF'
.vtt
.srt
.ass
.lrc
EOF
            )

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

    # Set parameters needed for when we will download a playlist

    PLAYLIST_SAVE_LIST_TO_FILE_ARGS=()

    # I don't know if --mtime works for playlists, but here is hoping it does:
    PLAYLIST_SAVE_LIST_TO_FILE_ARGS+=("--mtime")

    PLAYLISTS_DIRECTORY=playlists

    # The following are commands needed to save the playlist entries to a local file.
    PLAYLIST_SAVE_LIST_TO_FILE_ARGS+=("--skip-download" "-s" "--print-to-file" "|%(playlist_index)03d|%(uploader)s|%(title)s|%(uploader_id)s|%(upload_date,release_date)s|%(duration>%H:%M:%S)s|" "${PLAYLISTS_DIRECTORY}/%(playlist)s.txt" "--replace-in-metadata" "title" "[\|]+" "-")

    PLAYLIST_DISPLAY_URLS_ARGS=()

    # The following are commands needed to display the URLs in the playlist
    # Also needed is a followup with jq -r .url
    PLAYLIST_DISPLAY_URLS_ARGS+=("--flat-playlist" "-j")

    # Bring in arguments from $YTDL_ARGUMENTS

    if [[ -n "$YTDL_ARGUMENTS" ]]; then
        set -- $YTDL_ARGUMENTS "$@"
    fi

    TMPDIRBASE=""
    TMPDIR=""
    case $1 in
        -t | --tmpdir)
            TMPDIRBASE=$2
            shift 2

            # Check if the directory exists and is writable
            if [ ! -d "$TMPDIRBASE" ] || [ ! -w "$TMPDIRBASE" ]; then
                echo "Error: '$TMPDIRBASE' is not a writable directory."
                return 1
            fi

            # Create a unique temporary directory
            local TMPDIR
            TMPDIR=$(mktemp -d "$TMPDIRBASE/tmp.ytdl.$(date +"%Y%m%d_%H%M%S").XXXXXX")

            if [ ! -d "$TMPDIR" ]; then
                echo "Error: Failed to create temporary directory."
                return 1
            fi

        ;;
        -b | --browser)
            local USE_BROWSER=true
            local BROWSER_VALUE=$2
            VIDEO_DOWNLOADER_COMMAND_ARGS+=("--cookies-from-browser" "$BROWSER_VALUE") # man yt-dlp
            PLAYLIST_SAVE_LIST_TO_FILE_ARGS+=("--cookies-from-browser" "$BROWSER_VALUE") # man yt-dlp
            shift 2

        ;;
        *)

        ;;
    esac

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

            # *youtube.com/watch?v=*&list=PL*)
            # Do we add in a playlist grabber for any urls pasted in with a playlist on the end, such as:
            # https://www.youtube.com/watch?v=1FmBL5nAuaU&list=PLFVmIxMkvVDJwXMrAxgZfmpoW214Qa_EI
            # lol, well, I guess no. You must explicity specify by giving a /playlist? url
            # otherwise we'll just eventually run out of disk space on stuff we may not be interested in
            # ;;

            *youtube.com/shorts/*)
                VIDEO_HANDLE="[${URL##*/}]"
                echo "This is a youtube short, the id is the last field: ${VIDEO_HANDLE}" 1>&2
            ;;
            *youtube.com/watch?v=*)
                VIDEO_HANDLE="[${URL##*/}]"
                VIDEO_HANDLE=$(echo "${VIDEO_HANDLE}" | sed -e 's,watch?v=,,' -e 's,&.*$,,')
                echo "This is a regular youtube video, we picked out this as the video handle: ${VIDEO_HANDLE}" 1>&2
            ;;
            *youtube.com/playlist?list=*)
                # Nothing to do here, no video handle, the case statement further below will handle
                # the needed processing the playlist as well as bypassing normal video download operations
                # seeing that this is a playlist and not an individual video url
                echo "This is a youtube playlist, we will process it as a playlist." 1>&2
            ;;

            *)
                VIDEO_HANDLE="[${URL##*/}]"
                echo "No specific video handler built for this type of url so attempting to use last URL field: ${VIDEO_HANDLE}" 1>&2
            ;;
        esac

        (

            if [[ -n "${TMPDIR}" ]]; then
                # Change into the temporary directory
                cd "${TMPDIR}" || return 1
            else
                # Change to video directory
                cd "${DOMAIN_VIDEOS_DIRECTORY}" || exit 1
            fi

            DATESTAMP_NOW=$(date "+%Y-%m-%d %H:%M:%S %a")

            YTDLP_VERSION=$(${VIDEO_DOWNLOADER_COMMAND} --version)

            # Add entry to the logfile
            printf '[%s] [%s] [%s] [%s] %s\n' "${DATESTAMP_NOW}" "${script_name}" "${YTDLP_VERSION}" "${HOSTNAME}" "${URL}" >> "${DOMAIN_DOWNLOAD_LOG}"

            case "${URL}" in
                *youtube.com/playlist?list=*)

                    # https://www.youtube.com/playlist?list=PLFVmIxMkvVDJwXMrAxgZfmpoW214Qa_EI
                    # https://www.youtube.com/playlist?list=PLhRCbIq7GN_v7bIWNMRs-tAymIUUj2MyR

                    # https://youtube.com/playlist?list=PLpeFO20OwBF7iEECy0biLfP34s0j-8wzk
                    # https://www.youtube.com/playlist?list=PLRQGRBgN_EnrPrgmMGvrouKn7VlGGCx8m
                    # https://www.youtube.com/playlist?list=PLFVmIxMkvVDK-m_HAn2SfGTfNN8EGox16

                    # We are not going to just hand this playlist to yt-dlp, we want to run it through our special sauce that we have built up
                    # We don't want to get different results just because a file happens to be in a playlist.
                    # We will perform 2 actions 1) write the playlist to a local file and 2) send the list of URLs back through this program

                    # Part 1 - write the playlist listing to a local file

                    # Directory handler for playlists
                    mkdir -p "${PLAYLISTS_DIRECTORY}"

                    # Download the playlist file into the playlist directory
                    ${VIDEO_DOWNLOADER_COMMAND} "${PLAYLIST_SAVE_LIST_TO_FILE_ARGS[@]}" "${URL}" || echo "Failed to download: ${URL}"

                    # Part 2 - process the items from the playlist

                    # yt-dlp --flat-playlist -j https://www.youtube.com/playlist?list=PLhRCbIq7GN_v7bIWNMRs-tAymIUUj2MyR | jq -r .url

                    JSON_URLS_OUTPUT_LISTING=$(${VIDEO_DOWNLOADER_COMMAND} "${PLAYLIST_DISPLAY_URLS_ARGS[@]}" "${URL}") || echo "Failed to download: ${URL}"

                    # Call this function with all the video urls so they get processed normally
                    ${FUNCNAME[0]} $(echo "${JSON_URLS_OUTPUT_LISTING}" | jq -r .url)

                    # Since this is a playlist then we do not perform regular tasks, just processed the playlist, so skipping to top of loop
                    exit 0

                ;;

            esac

            # The steps from this point on do things like moving files to proper subdirs and
            # archiving thumbnails and subtitles.
            # The following is not useful for initial processing of the youtube playlist.

            # Perform the downloads for this single URL
            set -xv
            ${VIDEO_DOWNLOADER_COMMAND} "${VIDEO_DOWNLOADER_COMMAND_ARGS[@]}" "${URL}" || echo "Failed to download: ${URL}"
            set +xv

            # Get the earliest datestamp for this particular VIDEO_HANLE
            FILE_DATESTAMP_EARLIEST=$(find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -printf "%T@ %p\n" | sort -n | head -n 1)
            FILE_DATESTAMP_EARLIEST="${FILE_DATESTAMP_EARLIEST%% *}"

            # Locate the audio file so we can extract audio
            AUDIO_FILE=$(find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -printf "%p\n" | grep "${AUDIOS_FILE_EXTENSIONS}" | sort -n | head -n 1)

            # Use ffmpeg to extract the audio from the video into .mp3, 192k
            output_audio_filename="${AUDIO_FILE%\.[^\\.]*}.mp3"
            tmp_name="${output_audio_filename%.*.*}"
            tmp_ext="${output_audio_filename##*.}"
            mp3_filename="${tmp_name}.${tmp_ext}"
            ffmpeg -n -i "${AUDIO_FILE}" -vn -ab 192000 "${output_audio_filename}" && rm -v "${AUDIO_FILE}"
            # Rename without the .f140 portion just before .mp3
            mv -v "${output_audio_filename}" "${mp3_filename}"

            # Apply this timestamp to all files with this VIDEO_HANDLE - this code is optional and is standalone
            find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -exec touch -d "@${FILE_DATESTAMP_EARLIEST}" {} \;

            # Move desired video file and remove the others
            VIDEOS_DIRECTORY=videos
            VIDEOS_WORD=videos
            mkdir -p "${VIDEOS_DIRECTORY}"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${VIDEOS_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_VIDEOS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )

            local VIDEOS_LIST=()
            VIDEOS_LIST=("$(eval $FIND_VIDEOS_COMMAND | grep '\]\.mp4$')")
            VIDEOS_LIST+=("$(eval $FIND_VIDEOS_COMMAND | grep -v '\]\.mp4$')")
            mv -v "${VIDEOS_LIST[0]}" "${VIDEOS_DIRECTORY}"

            for ((i = 1; i < ${#VIDEOS_LIST[@]}; i++)); do
                rm -v "${VIDEOS_LIST[i]}"
            done

            # Move desired audio file and remove the others
            AUDIOS_DIRECTORY=audios
            AUDIOS_WORD=audios
            mkdir -p "${AUDIOS_DIRECTORY}"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${AUDIOS_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_AUDIOS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
EOF
            )

            local AUDIOS_LIST=()
            AUDIOS_LIST=("$(eval $FIND_AUDIOS_COMMAND | grep '\]\.mp3$')")
            AUDIOS_LIST+=("$(eval $FIND_AUDIOS_COMMAND | grep -v '\]\.mp3$')")
            mv -v "${AUDIOS_LIST[0]}" "${AUDIOS_DIRECTORY}"

            for ((i = 1; i < ${#AUDIOS_LIST[@]}; i++)); do
                rm -v "${AUDIOS_LIST[i]}"
            done

            # Archiving thumbnails
            THUMBNAILS_DIRECTORY=thumbnails
            THUMBNAILS_WORD=thumbnails
            mkdir -p "${THUMBNAILS_DIRECTORY}"

            THUMBNAILS_ARCHIVE_FILE="${VIDEO_HANDLE}_$(date -d "@${FILE_DATESTAMP_EARLIEST}" "+%Y%m%d_%H%M%S")_${THUMBNAILS_WORD}.tgz"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${THUMBNAIL_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_THUMBNAILS_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
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

            SUBTITLES_ARCHIVE_FILE="${VIDEO_HANDLE}_$(date -d "@${FILE_DATESTAMP_EARLIEST}" "+%Y%m%d_%H%M%S")_${SUBTITLES_WORD}.tgz"

            FIND_EXTENSIONS_ARGUMENTS=$(echo "${SUBTITLE_FILE_EXTENSIONS}" | sed -e 's,.*,-name "*&",' -e '2,$s,^,-o ,' | tr '\n' ' ')
            FIND_SUBTITLES_COMMAND=$(cat <<'EOF' | sed -e "s,\${VIDEO_HANDLE},${VIDEO_HANDLE},g" -e "s,\${FIND_EXTENSIONS_ARGUMENTS},${FIND_EXTENSIONS_ARGUMENTS},g"
find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -a \( ${FIND_EXTENSIONS_ARGUMENTS} \)
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

            # Function to move files and avoid overwriting
            move_with_suffix() {
                local src_file=$1
                local dest_dir=$2
                local base_name=$(basename "$src_file")
                local name="${base_name%.*}"   # Filename without extension
                local ext="${base_name##*.}"   # File extension
                local target="${dest_dir}/${base_name}"
            
                # Check for file conflicts and resolve with incrementing suffix
                if [[ -e "$target" ]]; then
                    local count=1
                    while [[ -e "${dest_dir}/${name} (${count}).${ext}" ]]; do
                        ((count++))
                    done
                    target="${dest_dir}/${name} (${count}).${ext}"
                fi
            
                # Move the file to the resolved target path
                mv -v "$src_file" "$target"
            }

            shopt -s nullglob

            if [[ -n "${TMPDIR}" ]]; then
                for dir in videos audios subtitles thumbnails; do
                    # Ensure the destination directory exists
                    mkdir -p "${DOMAIN_VIDEOS_DIRECTORY}/$dir"

                    # Process files in the current source directory
                    if compgen -G "${TMPDIR}/$dir/*" > /dev/null; then
                        for file in "${TMPDIR}/$dir/"*; do
                            move_with_suffix "$file" "${DOMAIN_VIDEOS_DIRECTORY}/$dir"
                        done
                    else
                        echo "No files to move from ${TMPDIR}/$dir/."
                    fi

                    # Remove the now-empty source directory
                    rmdir "${TMPDIR}/$dir"
                done
                rmdir "${TMPDIR}"
            else
                :
            fi

        )

        shift  # Move to the next argument
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

