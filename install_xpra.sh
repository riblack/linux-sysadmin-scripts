#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# FIXME: maybe set up a tmp dir and erase it when done?
# FIXME: this is followed with apt install xpra or dnf install xpra

install_xpra ()
{
    package=python3-pip
    dpkg -l $package | grep -qw ^ii || sudo apt install -y $package
    package=pkg-config
    dpkg -l $package | grep -qw ^ii || sudo apt install -y $package
#    package=python3-distutils
#    dpkg -l $package >/dev/null || sudo apt install $package
#    package=python3-setuptools
#    dpkg -l $package >/dev/null || sudo apt install $package
    git clone https://github.com/Xpra-org/xpra
    cd xpra
    ./setup.py install-repo
    sudo apt install -y xpra
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

