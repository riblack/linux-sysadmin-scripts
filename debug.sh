#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Debug function to run or display debug messages only when debug mode is enabled
debug ()
{
    if [ "${DEBUG_MODE:=0}" -eq 1 ]; then
        if type "$1" &> /dev/null; then
            "$@" 2>&1 | sed -e "s,^,DEBUG: ," 1>&2
        else
            echo "DEBUG: $@" 1>&2
        fi
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

