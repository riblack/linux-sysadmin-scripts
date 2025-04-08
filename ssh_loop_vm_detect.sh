#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

ssh_loop_vm_detect() {

    # Create timestamped output directory
    timestamp=$(date +%Y%m%d_%H%M%S)
    output_dir="$HOME/.ssh/SYSTEMS/output_$timestamp"
    mkdir -p "$output_dir"

    while read -r host 0<&3; do
        echo "Checking $host..."

        # Run detection script remotely and capture output + exit code
        output=$(ssh -o ConnectTimeout=5 "$host" 'bash -s' <detect_virtualization.sh 2>/dev/null)
        ssh_exit=$?

        if [ $ssh_exit -ne 0 ] || [ -z "$output" ]; then
            echo -e "\e[1;31mTimeout or unreachable: $host\e[0m"
            echo "$host" >>"$output_dir/output_timeout.out"
            continue
        fi

        # Display full remote result to screen
        echo "$output"

        # Extract TYPE line (structured result)
        type_line=$(echo "$output" | grep -E '^TYPE=')
        type_value=${type_line#TYPE=}

        # Get classification for output file (e.g., kvm, docker, physical)
        out_key=$(echo "$type_value" | awk -F: '{print $NF}')

        # Log just the hostname
        echo "$host" >>"$output_dir/output_${out_key}.out"
    done 3< <(cat "$HOME/.ssh/SYSTEMS/"{physical,down,kvm,other,test}.txt)
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
