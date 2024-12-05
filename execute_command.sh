#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display and execute a command
execute_command () 
{ 
    local cmd="$1"  # The command to execute
    shift           # Remove the first argument (the command itself)
    local args=("$@")  # The rest are the arguments

    # Construct the command for display
    local command_line="$cmd ${args[*]}"

    # Display the command
    echo "Executing command: $command_line" >&2

    # Execute the command
    "$cmd" ${args[@]}
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

