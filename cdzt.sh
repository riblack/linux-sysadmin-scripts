#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

# ---------------------------------------------------------------------------
# cdzt — Change Directory to Zim Templates
#
#   cdzt                 # jump to the wiki-template root
#   cdzt daily-journal   # jump to a specific template folder
#   cdzt -c              # create the directory if missing, then cd
#
# Env vars
#   ZIM_TEMPLATE_DIR   Override the root
# Options
#   -c, --create       mkdir -p the target if it doesn’t exist
# ---------------------------------------------------------------------------
cdzt() {
    local base="${ZIM_TEMPLATE_DIR:-$HOME/.local/share/zim/templates/wiki}"
    local do_create=0 subdir=

    # ---- option parsing ------------------------------------------------------
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c | --create) do_create=1 ;;
            *) subdir="$1" ;;
        esac
        shift
    done

    local dest="$base${subdir:+/$subdir}"

    # ---- ensure target exists (optionally create) ----------------------------
    if [[ ! -d $dest ]]; then
        if ((do_create)); then
            mkdir -p -- "$dest" || {
                printf 'cdzt: cannot create %s\n' "$dest" >&2
                return 1
            }
        else
            printf 'cdzt: %s does not exist (use --create?)\n' "$dest" >&2
            return 1
        fi
    fi

    cd -- "$dest" || return
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
