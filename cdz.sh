#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cdz() {
    ZIM_BASE_FALLBACK="${HOME}/Notebooks/Notes"
    ZIM_BASE_DIR="${ZIM_BASE_FALLBACK}/Journal"
    NOW_DAY=$(date +%Y/%m/%d)
    NOW_MONTH=$(date +%Y/%m)
    NOW_YEAR=$(date +%Y)
    ZIM_DIR="${ZIM_BASE_DIR}/$NOW_DAY"
    [ -d "${ZIM_DIR}" ] && cd "${ZIM_DIR}" && return
    ZIM_DIR="${ZIM_BASE_DIR}/$NOW_MONTH"
    [ -d "${ZIM_DIR}" ] && cd "${ZIM_DIR}" && return
    ZIM_DIR="${ZIM_BASE_DIR}/$NOW_YEAR"
    [ -d "${ZIM_DIR}" ] && cd "${ZIM_DIR}" && return
    ZIM_DIR="${ZIM_BASE_DIR}"
    [ -d "${ZIM_DIR}" ] && cd "${ZIM_DIR}" && return
    ZIM_DIR="${ZIM_BASE_FALLBACK}"
    [ -d "${ZIM_DIR}" ] && cd "${ZIM_DIR}" && return
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi
