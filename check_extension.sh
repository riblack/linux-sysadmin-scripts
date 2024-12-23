#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. load_color_codes.def

# Check if script has .sh extension
check_extension() {
    local script="$1"
    if [[ "$script" != *.sh ]]; then
        echo -e "  ${red}[FAILED] File does not have .sh extension.${reset}"
        return 1
    else
        echo -e "  ${green}[OK] File has .sh extension.${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

