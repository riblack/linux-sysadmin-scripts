#!/usr/bin/env bash

install_parabolic ()
{
    sudo add-apt-repository ppa:xtradeb/apps -y
    sudo apt update
    sudo apt install parabolic
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

