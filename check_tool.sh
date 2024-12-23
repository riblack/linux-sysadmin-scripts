#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./print_status.sh

check_tool() {
    local tool=$1
    if command -v "$tool" &>/dev/null; then
        print_status "installed" "$tool is installed"
    else
        print_status "not_installed" "$tool is NOT installed"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

