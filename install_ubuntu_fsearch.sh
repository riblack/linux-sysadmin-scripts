#!/usr/bin/env bash

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
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

