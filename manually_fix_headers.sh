#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

manually_fix_headers() {

    BACKUP_DIR="/data/backups"
    mkdir -p "$BACKUP_DIR"

    for script in *.sh; do
        if ! ./check_header.sh "$script"; then
            echo "Fixing header in $script..."

            # Prep names and paths
            script_basename="${script%.sh}"
            script_mtime=$(stat -c %Y "$script")
            script_mtime_human=$(date -d @"$script_mtime" +%Y%m%d_%H%M%S)
            backup_filename="${script_basename}_${script_mtime_human}.sh"
            backup_path="$BACKUP_DIR/$backup_filename"

            # Collision detection via md5
            if [[ -e "$backup_path" ]]; then
                if ! cmp -s "$script" "$backup_path"; then
                    echo "Backup name collision with differing content detected."

                    now_stamp=$(date +%Y%m%d_%H%M%S)
                    backup_filename="${script_basename}_${script_mtime_human}_${now_stamp}.sh"
                    backup_path="$BACKUP_DIR/$backup_filename"
                else
                    echo "Identical backup already exists at $backup_path"
                fi
            fi

            # Create backup
            cp "$script" "$backup_path"
            echo "Backup saved to $backup_path"

            # Prepare temporary fixed script
            timestamp=$(date +%Y%m%d%H%M%S)
            temp_script="/tmp/${script_basename}_patched_${timestamp}.sh"
            cat bash_header.template.stub "$script" >"$temp_script"
            initial_mtime=$(stat -c %Y "$temp_script")

            # Open editor
            vim "$temp_script"

            # Detect if saved
            final_mtime=$(stat -c %Y "$temp_script")
            if [[ "$initial_mtime" -ne "$final_mtime" ]]; then
                echo "Changes saved — updating $script"
                mv "$temp_script" "$script"
            else
                echo "No changes saved — $script left untouched"
                rm "$temp_script"
            fi
        fi
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
