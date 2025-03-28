#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

. ./lss_backup.sh

manually_fix_headers() {

    for script in *.sh; do
        if ! ./check_header.sh "$script"; then
            echo "Fixing header in $script..."

            lss_backup_file "$script"

            # Create and open patched version
            script_basename="${script%.sh}"
            temp_script="/tmp/${script_basename}_patched_$(date +%Y%m%d%H%M%S).sh"
            cat bash_header.template.stub "$script" >"$temp_script"
            initial_mtime=$(stat -c %Y "$temp_script")

            vim "$temp_script"

            if [[ "$(stat -c %Y "$temp_script")" -ne "$initial_mtime" ]]; then
                mv "$temp_script" "$script"
                echo "Updated $script"
            else
                echo "No changes saved — skipping overwrite"
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
