#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ipa_change_user_shell () 
{ 

    # Check if the script is run as root or with sudo
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root or with sudo privileges." 
       exit 1
    fi

    # Check if the ipa command is available
    if ! command -v ipa &> /dev/null; then
        echo "The 'ipa' command could not be found. Please install the FreeIPA client tools."
        exit 1
    fi

    # Check if at least one username is provided
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 username1 [username2 ... usernameN]"
        exit 1
    fi

    # Loop through all provided usernames
    for username in "$@"; do
        echo "Processing user: $username"

        # Confirm if the user exists in FreeIPA
        if ! ipa user-show "$username" &> /dev/null; then
            echo "User '$username' does not exist in FreeIPA. Skipping."
            continue
        fi

        # Change the user's shell to /bin/bash
        ipa user-mod "$username" --shell=/bin/bash

        # Check if the command was successful
        if [[ $? -eq 0 ]]; then
            echo "Shell for user '$username' has been successfully changed to /bin/bash."
        else
            echo "Failed to change the shell for user '$username'."
        fi
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

