#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

log_info() {
    # Fields

    # INFO
    # Datestamp
    # Hostname
    # Script name
    # Error message

    DATESTAMP_NOW=$(date "+%Y-%m-%d %H:%M:%S %a")

    printf '[INFO] [%s] [%s] [%s] %s\n' "${DATESTAMP_NOW}" "${HOSTNAME}" "$0" "$*"

    return 1
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
