#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. dpkg_remove.sh
. dpkg_install.sh

# Function to install or configure yt-dlp based on the system's codename
i_install_yt_dlp ()
{
    local package="yt-dlp"

    # Retrieve the OS codename
    local codename
    codename=$(grep VERSION_CODENAME /etc/os-release)
    codename=${codename#*=}

    # Ensure the codename is not empty
    if [[ -z "$codename" ]]; then
        echo "Error: Unable to determine OS codename."
        return 1
    fi

    # Perform actions based on the codename
    case "$codename" in
        jammy)
            echo "Detected codename: $codename (Ubuntu 22.04)"

            # Remove yt-dlp via dpkg if installed, then install it via snap
            dpkg_remove "$package"
            if ! snap list "$package" &>/dev/null; then
                echo "Installing $package via snap..."
                snap install "$package"
            else
                echo "$package is already installed via snap."
            fi

            # Ensure ffmpeg is installed
            if ! dpkg -l ffmpeg | grep -q '^ii'; then
                echo "Installing ffmpeg..."
                sudo apt-get install -y ffmpeg
            else
                echo "ffmpeg is already installed."
            fi
            ;;
        *)
            echo "Detected codename: $codename (Other distributions)"

            # Remove yt-dlp via snap if installed, then install it via dpkg/apt
            if snap list "$package" &>/dev/null; then
                echo "Removing $package via snap..."
                snap remove "$package"
            else
                echo "$package is not installed via snap."
            fi

            # Install yt-dlp via dpkg/apt
            dpkg_install "$package"
            ;;
    esac
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

