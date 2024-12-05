#!/usr/bin/env bash

install_parabolic ()
{
    sudo add-apt-repository ppa:xtradeb/apps -y
    sudo apt update
    sudo apt install parabolic
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

