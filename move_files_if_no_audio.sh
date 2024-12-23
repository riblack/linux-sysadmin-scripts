#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/move_with_suffix.sh"

move_files_if_no_audio ()
{
    local hold_directory="audio_missing_directory"
    local list_of_moved=()

    while read -r file 0<&3; do
        if [[ -f "$file" ]]; then

            if ffprobe -i "$file" -show_streams -select_streams a -loglevel error | grep -q 'codec_name'; then
                echo "File '$file' has audio." >&2
            else
                echo "File '$file' does not have audio." >&2

                if [[ -e "$file" ]]; then

                    # Ensure the directory exists
                    mkdir -p "$hold_directory"

                    local output
                    output=$(move_with_suffix "$file" "$hold_directory/" 2>&1)
                    if [[ $? -eq 0 ]]; then
                        list_of_moved+=("$output")
                    else
                        echo "Error moving file: $file" >&2
                    fi
                fi
            fi
        fi
    done 3< <(find . -maxdepth 1 -type f)

    if (( ${#list_of_moved[@]} > 0 )); then
        echo "The following files were moved:"
        for entry in "${list_of_moved[@]}"; do
            ls -ld "$entry"
        done
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

