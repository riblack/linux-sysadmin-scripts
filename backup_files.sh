#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./load_color_codes.def

# Function to backup files
backup_files ()
{
    local files=("$@")
    mkdir -p /data/backups

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            cp -avi "$file" "/data/backups/$(basename "$file")_$(date "+%Y%m%d_%H%M%S").bak"
        else
            echo "Warning: File '$file' does not exist. Skipping backup for this file."
        fi
    done
    echo "Backup completed for specified files."
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

