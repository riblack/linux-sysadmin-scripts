#!/usr/bin/env bash

install_ksnip ()
{
    sudo apt install ksnip
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

