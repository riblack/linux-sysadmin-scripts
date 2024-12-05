#!/usr/bin/env bash

update_ubuntu () 
{ 
    sudo apt update -y || return 1
    apt list --upgradable
    sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo aptitude update -y && sudo aptitude upgrade -y && sudo killall snap-store && sudo snap refresh
    package=fwupd
    dpkg -l $package | grep -qw ^ii || sudo apt install -y $package
    fwupdmgr refresh --force && fwupdmgr get-updates && fwupdmgr update
    ### # Other fwupdmgr commands
    ### fwupdmgr --help
    ### fwupdmgr --version
    ### fwupdmgr get-devices
    ### # Alias to fwupdmgr update
    ### fwupdmgr upgrade
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

