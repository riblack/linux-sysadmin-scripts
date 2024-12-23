#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. load_color_codes.def

# Check if script exists
check_file_exists() {
    local script="$1"
    if [[ ! -f "$script" ]]; then
        echo -e "  ${red}[FAILED] File does not exist.${reset}"
        return 1
    else
        echo -e "  ${green}[OK] File exists.${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

