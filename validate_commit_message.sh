#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to validate commit message
validate_commit_message ()
{
    local template="$1"
    local subject body
    subject=$(sed '/^#/d' "$template" | sed -n '1p')
    body=$(sed '/^#/d' "$template" | sed -n '2,$p' | sed '/./,$!d' | tac | sed '/./,$!d' | tac)

    # Check the 50/72 rule
    if [[ ${#subject} -gt 50 ]]; then
        echo "Warning: The subject line exceeds 50 characters (${#subject})."
    fi

    if echo "$body" | grep -q '.\{73\}'; then
        echo "Warning: One or more lines in the body exceed 72 characters."
    fi

    # Ask user to retry or continue
    while true; do
        read -p "Do you want to retry editing the commit message? (y/n): " choice
        case "$choice" in
            y|Y)
                vim "$template"
                validate_commit_message "$template" # Recursive check after re-edit
                return
                ;;
            n|N)
                echo "Proceeding despite rule violations."
                return
                ;;
            *)
                echo "Please enter 'y' or 'n'."
                ;;
        esac
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

