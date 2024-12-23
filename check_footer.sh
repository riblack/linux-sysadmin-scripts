#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. load_color_codes.def

# Check for footer template
check_footer() {
    local script="$1"

    # Template for footer
    FOOTER_TEMPLATE="bash_footer.template.stub"

    local lines_in_footer=$(wc -l < "$FOOTER_TEMPLATE")

    if ! tail -n "$lines_in_footer" "$script" | diff -q "$FOOTER_TEMPLATE" - >/dev/null; then
        echo -e "  ${red}[FAILED] Missing or incorrect footer.${reset}"
        return 1
    else
        echo -e "  ${green}[OK] Footer is correct.${reset}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

