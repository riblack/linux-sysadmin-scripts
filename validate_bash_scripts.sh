#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/check_file_exists.sh"
. "$SCRIPT_DIR/check_extension.sh"
. "$SCRIPT_DIR/check_executable.sh"
. "$SCRIPT_DIR/check_header.sh"
. "$SCRIPT_DIR/check_footer.sh"
. "$SCRIPT_DIR/check_function_name.sh"

# Validate a Bash scripts
validate_bash_scripts ()
{

    # Main script
    if [[ $# -eq 0 ]]; then
        echo -e "Usage: $0 <script1> [script2 ...]"
        exit 1
    fi

    local script
    for script in "$@"; do
        local validation_failed=0

        echo -e "Checking script: $script"

        check_file_exists "$script" || validation_failed=1
        check_extension "$script" || validation_failed=1
        check_executable "$script" || validation_failed=1
        check_header "$script" || validation_failed=1
        check_footer "$script" || validation_failed=1
        check_function_name "$script" || validation_failed=1

        if [[ $validation_failed -eq 0 ]]; then
            echo -e "${green}Validation completed successfully for $script.${reset}"
        else
            echo -e "${red}Validation failed for $script.${reset}"
        fi
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

