#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. load_color_codes.def

# Check for header template
check_header() {
    local script="$1"

    # Template for header
    HEADER_TEMPLATE="bash_header.template"

    local lines_in_header=$(wc -l < "$HEADER_TEMPLATE")
    if ! head -n "$lines_in_header" "$script" | diff -q "$HEADER_TEMPLATE" - >/dev/null; then
        echo -e "  ${red}[FAILED] Missing or incorrect header.${reset}"
        return 1
    else
        echo -e "  ${green}[OK] Header is correct.${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

