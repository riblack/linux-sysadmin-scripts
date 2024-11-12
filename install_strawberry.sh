#!/usr/bin/env bash

install_strawberry ()
{
    sudo add-apt-repository ppa:jonaski/strawberry
    sudo apt update
    sudo apt install strawberry
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

