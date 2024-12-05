#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cds () 
{ 
    SCRIPTS_DIR="${HOME}/scripts"
    [ -d "${SCRIPTS_DIR}" ] || mkdir -p "${SCRIPTS_DIR}"
    cd "${SCRIPTS_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

