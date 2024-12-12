#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. dpkg_remove.sh
. dpkg_install.sh

i_install_yt_dlp ()
{ 
    package=yt-dlp;
    codename=$(grep VERSION_CODENAME /etc/os-release);
    codename=${codename#*=}
    case $codename in 
        jammy)
            # dpkg -l $package | grep '^ii' && sudo apt remove $package;
            dpkg_remove $package
            snap list $package || snap install $package
            dpkg -l ffmpeg | grep '^ii' || sudo apt install ffmpeg
        ;;
        *)
            snap list $package || snap remove $package
            # dpkg -l $package | grep '^ii' || sudo apt install $package
            dpkg_install $package
        ;;
    esac
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

