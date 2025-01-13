#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to move files and avoid overwriting
move_with_suffix ()
{
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
    if [[ -e "$src_file" ]]; then
        mv -v "$src_file" "$target"
        result=$?
        if [[ $result -eq 0 ]]; then
            echo "$target"
            return 0
        else
            return $result
        fi
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

