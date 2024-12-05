#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

error () 
{ 
    # Fields

    # ERROR:
    # Datestamp
    # Hostname
    # Script name
    # Error message

    DATESTAMP_NOW=$(date "+%Y-%m-%d %H:%M:%S %a")

    printf 'ERROR: [%s] [%s] [%s] %s\n' "${DATESTAMP_NOW}" "${HOSTNAME}" "$0" "$@" 1>&2

    return 1
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

