#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace"
    [ -d "${WORKSPACE_DIR}" ] || mkdir -p "${WORKSPACE_DIR}"
    cd "${WORKSPACE_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

