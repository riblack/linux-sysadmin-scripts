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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

