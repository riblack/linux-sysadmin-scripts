#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to remove a package using dpkg/apt
dpkg_remove ()
{
    local package="$1"

    # Check if the package name is provided
    if [[ -z "$package" ]]; then
        echo "Error: You must specify a package to remove."
        return 1
    fi

    # Check if the package is installed
    if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
        echo "Package ($package) is currently installed. Details:"
        dpkg-query -W -f='${binary:Package}\t${Version}\n' "$package"
        echo "Removing package ($package)..."
        if sudo apt-get remove -y "$package"; then
            echo "Package ($package) removed successfully."
        else
            echo "Error: Failed to remove package ($package)."
            return 2
        fi
    else
        echo "Package ($package) is not installed. No action needed."
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

