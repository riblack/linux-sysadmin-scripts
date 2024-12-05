#!/usr/bin/env bash

. execute_command.sh

find_files_not_mine () 
{ 

# Main script logic
if [ $# -lt 2 ]; then
    echo "Usage: $0 <directory> <user> [<group1> [<group2> ... <groupN>]]"
    exit 1
fi

DIRECTORY=$1
USER=$2
shift 2  # Remove the directory and user arguments
SPECIFIED_GROUPS=("$@")  # Store remaining arguments as an array of specified groups

# Create find command options
# FIND_OPTIONS=("-type" "f" "! -user" "$USER")
FIND_OPTIONS=("! -user" "$USER")

# Check if any groups were provided and add group conditions if so
if [ ${#SPECIFIED_GROUPS[@]} -gt 0 ]; then
    GROUP_CONDITIONS=()

    # Handle the first group condition without leading -o
    GROUP_CONDITIONS+=("! -group" "${SPECIFIED_GROUPS[0]}")

    # Process remaining group conditions with leading -o
    for GROUP in "${SPECIFIED_GROUPS[@]:1}"; do
        GROUP_CONDITIONS+=("-a" "! -group" "$GROUP")
    done

    # Combine the find options and group conditions
    FIND_OPTIONS+=("-o" "(" "${GROUP_CONDITIONS[@]}" ")")
fi

# Call the execute_command function with find command and options
execute_command find "$DIRECTORY" "${FIND_OPTIONS[@]}"

}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

