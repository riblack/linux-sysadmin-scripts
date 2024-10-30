#!/usr/bin/env bash

root_rename_user () 
{ 

    # Check if the script is run with root privileges
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root."
        exit 1
    fi

    # Check if the correct number of arguments is provided
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <old_username> <new_username>"
        exit 1
    fi

    old_username="$1"
    new_username="$2"

    # Check if the old username exists
    if ! id "$old_username" &> /dev/null; then
        echo "User '$old_username' does not exist."
        exit 1
    fi

    # Check if the new username already exists
    if id "$new_username" &> /dev/null; then
        echo "User '$new_username' already exists."
        exit 1
    fi

    # Check if the old username has any running processes
    if pgrep -u "$old_username" >/dev/null; then
        echo "User '$old_username' has running processes."
        pgrep -u "$old_username" -l # Optionally list the processes
        echo
        echo "Alternatively you could do this in runlevel 1 (init 1)."
        exit 1
    fi

    # Check if the new username has any running processes
    if pgrep -u "$new_username" >/dev/null; then
        echo "User '$new_username' has running processes."
        pgrep -u "$new_username" -l # Optionally list the processes
        echo
        echo "Alternatively you could do this in runlevel 1 (init 1)."
        exit 1
    fi

    # Rename the user account
    usermod -l "$new_username" "$old_username" || {
    echo "There was an error renaming the user account."
    exit 1
    }

    # Rename the group account
    groupmod -n "$new_username" "$old_username" || {
    echo "There was an error renaming the user group."
    exit 1
    }

    # Rename the home directory
    if [ -d "/home/$old_username" ] && [ ! -d "/home/$new_username" ]; then
        mv -vi "/home/$old_username" "/home/$new_username"
    else
        if [ ! -d "/home/$old_username" ]; then
            echo "Old home directory '/home/$old_username' does not exist."
        fi
        if [ -d "/home/$new_username" ]; then
            echo "New home directory '/home/$new_username' already exists."
        fi
        exit 1
    fi

    # Update the user account with the new home directory
    usermod -d "/home/$new_username" "$new_username" || {
    echo "There was an error updating the home directory entry in the account."
    exit 1
    }

    # Update the ownership of the home directory
    chown -R "$new_username":"$new_username" "/home/$new_username"

    echo "User '$old_username' has been renamed to '$new_username'."
}

# Source the footer
source bash_footer.template.live

