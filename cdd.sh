#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdd () 
{ 
    DOWNLOAD_DIR="${HOME}/Downloads"
    [ -d "${DOWNLOAD_DIR}" ] && cd "${DOWNLOAD_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

