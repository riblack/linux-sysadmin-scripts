#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdzt() {
    ZIM_TEMPLATE_DIR="${HOME}/.local/share/zim/templates/wiki"
    [ -d "${ZIM_TEMPLATE_DIR}" ] && cd "${ZIM_TEMPLATE_DIR}"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi
