#!/usr/bin/env bash

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

# Source the footer
source bash_footer.template.live

