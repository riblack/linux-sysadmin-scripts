#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

cdp() {
    LAST_PROJECT_NAME=$(
        cd "${HOME}/workspace"
        ls -tr | tail -n 1
    )
    LAST_PROJECT_DIR="${HOME}/workspace/${LAST_PROJECT_NAME}"
    [ -d "${LAST_PROJECT_DIR}" ] && cd "${LAST_PROJECT_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
