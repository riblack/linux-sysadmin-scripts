#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

# Debug function to run or display debug messages only when debug mode is enabled
debug() {
    if [ "${DEBUG_MODE:=0}" -eq 1 ]; then
        if type "$1" &>/dev/null; then
            if [[ "$1" == "set" ]]; then
                # Run 'set' command bare so options like -xv take effect
                "$@"
            else
                "$@" 2>&1 | sed -e "s,^,DEBUG: ," 1>&2
            fi
        else
            echo "DEBUG: $*" 1>&2
        fi
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
