#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

ssh_loop_vm_detect() {

    while read -r host 0<&3; do
        echo "Checking $host..."

        # Run detection script remotely
        output=$(ssh -o ConnectTimeout=5 "$host" 'bash -s' <detect_virtualization.sh 2>/dev/null)

        # Print result to screen
        echo "$output"

        # Extract TYPE line from output (last line)
        type_line=$(echo "$output" | grep -E '^TYPE=')

        # Get just the classification (e.g., physical, virtual:vmware, container:docker)
        type_value=${type_line#TYPE=}

        # Use only the last part after ":" or full word if not present
        out_key=$(echo "$type_value" | awk -F: '{print $NF}')

        # Write entire result to corresponding file
        echo -e "[$host]\n$output\n" >>"output_${out_key}.out"
    done 3<~/.ssh/SYSTEMS/servers.txt
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
