#!/usr/bin/env bash

install_strawberry ()
{
    sudo add-apt-repository ppa:jonaski/strawberry
    sudo apt update
    sudo apt install strawberry
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

