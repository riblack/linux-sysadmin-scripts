#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Normal function that only operates when debug mode is disabled
normal ()
{
    if [ "${DEBUG_MODE:=0}" -eq 0 ]; then
        if type "$1" &> /dev/null; then
            "$@"
        else
            echo "$@" 1>&2
        fi
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

