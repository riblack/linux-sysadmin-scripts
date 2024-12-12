#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to install a package using dpkg/apt
dpkg_install ()
{
    local package="$1"

    # Check if the package name is provided
    if [[ -z "$package" ]]; then
        echo "Error: You must specify a package to install."
        return 1
    fi

    # Check if the package is already installed
    if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
        echo "Package ($package) is already installed. Details:"
        dpkg-query -W -f='${binary:Package}\t${Version}\n' "$package"
    else
        # Attempt to install the package
        echo "Package ($package) is not installed. Installing..."
        if sudo apt-get install -y "$package"; then
            echo "Package ($package) installed successfully."
        else
            echo "Error: Failed to install package ($package)."
            return 2
        fi
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

