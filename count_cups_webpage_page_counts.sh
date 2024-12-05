#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

count_cups_webpage_page_counts () 
{ 
    file="$1";
    printer="$2";
    cat "$file" | grep --color=auto "$printer" | cut -d'	' -f5 | awk '{sum += $NF} END {print "Total Pages Printed: ", sum}'
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

