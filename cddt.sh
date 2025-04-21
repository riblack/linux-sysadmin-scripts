#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

cddt() {
    TODAY_DATE=$(date +%Y/%m/%d)
    DOWNLOAD_DIR="${HOME}/Downloads"
    TODAY_DIR=${DOWNLOAD_DIR}/${TODAY_DATE}
    if [ -d "${TODAY_DIR}" ]; then
        cd "${TODAY_DIR}" || return
        result=$?
        if [ $result -ne 0 ]; then
            cd "${DOWNLOAD_DIR}" || return
        fi
    else
        cd "${DOWNLOAD_DIR}" || return
    fi

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
