#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

generate_vm_report() {
    local report_dir="${1:-.}" # Optional argument: path to directory with output_*.out files
    local indent="    "

    # Enter the report directory
    pushd "$report_dir" >/dev/null || {
        echo "Failed to enter directory: $report_dir"
        return 1
    }

    # Iterate over all .out files
    while read -r OUTFILE 0<&4; do
        echo
        echo "===== ===== $OUTFILE ===== ====="

        # For each word/host in the OUTFILE
        while read -r word 0<&3; do
            # Search in parent directory text files
            result=$(grep -H --color=always "$word" ../*.txt)
            if [ -n "$result" ]; then
                echo "$indent$result"
            else
                echo "${indent}NOT FOUND $word"
            fi
        done 3<"$OUTFILE"
    done 4< <(ls -- *.out)

    # Leave the report directory
    popd >/dev/null || return
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
