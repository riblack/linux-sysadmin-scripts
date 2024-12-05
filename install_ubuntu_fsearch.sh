#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_ubuntu_fsearch ()
{
    sudo add-apt-repository ppa:christian-boxdoerfer/fsearch-stable
    before=$( sudo apt search fsearch )
    sudo apt update
    after=$( sudo apt search fsearch )
    diff -Naurb <( echo "$before" ) <( echo "$after" )
    sudo apt install fsearch
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

