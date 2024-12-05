#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdp () 
{ 
    LAST_PROJECT_NAME=$( cd "${HOME}/workspace"; ls -tr | tail -n 1 )
    LAST_PROJECT_DIR="${HOME}/workspace/${LAST_PROJECT_NAME}"
    [ -d "${LAST_PROJECT_DIR}" ] && cd "${LAST_PROJECT_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

