#!/usr/bin/env bash

# FIXME: maybe set up a tmp dir and erase it when done?
# FIXME: this is followed with apt install xpra or dnf install xpra

install_xpra ()
{
    git clone https://github.com/Xpra-org/xpra
    cd xpra
    ./setup.py install-repo
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

