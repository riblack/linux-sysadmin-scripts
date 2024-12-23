#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. load_color_codes.def

# Check if the script contains a function matching its filename
check_function_name() {
    local script="$1"
    local script_name="$(basename "$script" .sh)"
    if ! grep -q -E "^\s*function\s+$script_name\s*\(\)" "$script" && ! grep -q -E "^\s*$script_name\s*\(\)" "$script"; then
        echo -e "  ${red}[FAILED] Function $script_name is missing or not defined correctly.${reset}"
        return 1
    else
        echo -e "  ${green}[OK] Function $script_name is defined.${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

