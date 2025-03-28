#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

manually_fix_headers() {
    for f in *.sh; do
        if ! ./check_header.sh "$f"; then
            echo "Fixing header in $f..."
            tmpfile=$(mktemp)
            cat bash_header.template.stub "$f" >"$tmpfile"
            mv -v "$tmpfile" "$f"
            vim "$f"
        else
            continue
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
