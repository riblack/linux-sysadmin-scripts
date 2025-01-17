#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create and structure the .ssh directory for a specified user
create_ssh_structure ()
{
    if [ -z "$1" ]; then
        echo "Usage: create_ssh_structure <username>"
        return 1
    fi

    local target_user=$1
    local home_dir

    case "$target_user" in
        root)
            home_dir="/root"
            ;;
        *)
            home_dir="/home/$target_user"
            ;;
    esac

    if [ ! -d "$home_dir" ]; then
        echo "Error: The home directory for user '$target_user' does not exist."
        return 1
    fi

    # Ensure the .ssh directory exists
    if [ ! -d "$home_dir/.ssh" ]; then
        mkdir -p "$home_dir/.ssh"
    fi
    chown "$target_user":"$target_user" "$home_dir/.ssh"
    chmod 0700 "$home_dir/.ssh"

    # Create authorized_keys if it doesn't exist
    if [ ! -e "$home_dir/.ssh/authorized_keys" ]; then
        touch "$home_dir/.ssh/authorized_keys"
    fi
    chown "$target_user":"$target_user" "$home_dir/.ssh/authorized_keys"
    chmod 0600 "$home_dir/.ssh/authorized_keys"

    # Ensure proper ownership and permissions for id_rsa if it exists
    if [ -e "$home_dir/.ssh/id_rsa" ]; then
        chown "$target_user":"$target_user" "$home_dir/.ssh/id_rsa"
        chmod 0600 "$home_dir/.ssh/id_rsa"
    fi

    # Ensure proper ownership and permissions for id_rsa.pub if it exists
    if [ -e "$home_dir/.ssh/id_rsa.pub" ]; then
        chown "$target_user":"$target_user" "$home_dir/.ssh/id_rsa.pub"
        chmod 0644 "$home_dir/.ssh/id_rsa.pub"
    fi

    # Create known_hosts if it doesn't exist
    if [ ! -e "$home_dir/.ssh/known_hosts" ]; then
        touch "$home_dir/.ssh/known_hosts"
    fi
    chown "$target_user":"$target_user" "$home_dir/.ssh/known_hosts"
    chmod 0600 "$home_dir/.ssh/known_hosts"
}

# Export the function for use in the current shell
export -f create_ssh_structure

# Example usage: Uncomment the line below to call the function with 'root' as the user
# create_ssh_structure root

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

