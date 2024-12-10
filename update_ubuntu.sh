#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

update_ubuntu () 
{ 

    package=apt
    dpkg -l $package | grep -qw ^ii && {
        sudo apt-get -y update || return 1
        apt list --upgradable
        sudo apt-get -y upgrade || return 1
        sudo apt-get -y dist-upgrade || return 1
        sudo apt autoremove || return 1
    }

    package=aptitude 
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        sudo aptitude -y update || return 1
        sudo aptitude -y upgrade || return 1
    }

    package=snapd
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        sudo killall snap-store
        sudo snap refresh || return 1
    }

    package=fwupd
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        fwupdmgr refresh --force || return 1
        fwupdmgr get-updates
        fwupdmgr update || return 1
        ### # Other fwupdmgr commands
        ### fwupdmgr --help
        ### fwupdmgr --version
        ### fwupdmgr get-devices
        ### # Alias to fwupdmgr update
        ### fwupdmgr upgrade
    }
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

