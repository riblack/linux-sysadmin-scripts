#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./load_color_codes.def

# Function to print colored messages
print_status() {
    local status=$1
    local message=$2

    if [[ $status == "installed" ]]; then
        # Green for installed
        echo -e "${green}$message${reset}"
    else
        # Red for not installed
        echo -e "${red}$message${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

