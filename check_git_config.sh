#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check git user configuration
check_git_config ()
{
    local name email
    name=$(git config --get user.name)
    email=$(git config --get user.email)

    if [[ -z "$name" || -z "$email" ]]; then
        echo "Error: Git user.name or user.email is not set."
        echo "Please set them using the following commands:"
        echo "  git config --global user.name 'Your Name'"
        echo "  git config --global user.email 'your.email@example.com'"
        exit 1
    fi
    echo "Git is configured with:"
    echo "  Name: $name"
    echo "  Email: $email"
    echo
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

