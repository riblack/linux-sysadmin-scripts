#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read_bash_history_with_time () 
{ 
    if [[ -n "$1" ]]; then
        # If a filename is provided, read from the file
        awk -F \\n '{ if ($0 ~ /^#[0-9]+/) {printf "%5d  %s ", ++i, strftime("%d/%m/%y %T", substr($1,2)); getline; print $0 }}' "$1"
    else
        # Otherwise, read from stdin
        awk -F \\n '{ if ($0 ~ /^#[0-9]+/) {printf "%5d  %s ", ++i, strftime("%d/%m/%y %T", substr($1,2)); getline; print $0 }}'
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

