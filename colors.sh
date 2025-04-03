#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

colors() {

    # colors.sh — centralized ANSI color definitions for Bash scripting

    USE_COLORS="${USE_COLORS:-yes}"

    if [[ "$USE_COLORS" == "yes" ]]; then
        txt_reset="\033[0m"
        txt_bold="\033[1m"
        txt_dim="\033[2m"
        txt_underline="\033[4m"
        txt_blink="\033[5m"
        txt_reverse="\033[7m"

        fg_black="\033[0;30m"
        fg_red="\033[0;31m"
        fg_green="\033[0;32m"
        fg_yellow="\033[0;33m"
        fg_blue="\033[0;34m"
        fg_magenta="\033[0;35m"
        fg_cyan="\033[0;36m"
        fg_white="\033[0;37m"

        fg_bblack="\033[1;30m"
        fg_bred="\033[1;31m"
        fg_bgreen="\033[1;32m"
        fg_byellow="\033[1;33m"
        fg_bblue="\033[1;34m"
        fg_bmagenta="\033[1;35m"
        fg_bcyan="\033[1;36m"
        fg_bwhite="\033[1;37m"

        bg_black="\033[40m"
        bg_red="\033[41m"
        bg_green="\033[42m"
        bg_yellow="\033[43m"
        bg_blue="\033[44m"
        bg_magenta="\033[45m"
        bg_cyan="\033[46m"
        bg_white="\033[47m"
    else
        txt_reset=""
        txt_bold=""
        txt_dim=""
        txt_underline=""
        txt_blink=""
        txt_reverse=""
        for color in black red green yellow blue magenta cyan white; do
            eval "fg_${color}=''"
            eval "fg_b${color}=''"
            eval "bg_${color}=''"
        done
    fi

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
