#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

cddt() {
    DOWNLOAD_DIR="${HOME}/Downloads"
    TODAY=$(date +%Y/%m/%d)

    # Use find to get all YYYY/MM/DD paths directly under ~/Downloads
    mapfile -t dated_dirs < <(find "$DOWNLOAD_DIR" -mindepth 3 -maxdepth 3 -type d \
        -regextype posix-extended \
        -regex ".*/[0-9]{4}/[0-9]{2}/[0-9]{2}$" \
        | sed "s|$DOWNLOAD_DIR/||" | sort)

    latest=""
    for dir in "${dated_dirs[@]}"; do
        if [[ "$dir" > "$TODAY" ]]; then
            continue
        fi
        latest="$dir"
    done

    if [ -n "$latest" ]; then
        target_dir="${DOWNLOAD_DIR}/${latest}"
        echo "📂 Navigating to latest dated directory: $target_dir"
        cd "$target_dir" || {
            echo "❌ Failed to cd into $target_dir"
            cd "$DOWNLOAD_DIR" || return
        }
    else
        echo "⚠️ No suitable YYYY/MM/DD directory found. Falling back to: $DOWNLOAD_DIR"
        cd "$DOWNLOAD_DIR" || echo "❌ Failed to cd into $DOWNLOAD_DIR"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
