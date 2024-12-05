#!/usr/bin/env bash

install_ksnip ()
{
    sudo apt install ksnip
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

