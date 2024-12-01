#!/usr/bin/env bash

update_ubuntu () 
{ 
    sudo apt update -y || return 1
    apt list --upgradable
    sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo aptitude update -y && sudo aptitude upgrade -y && sudo killall snap-store && sudo snap refresh
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

