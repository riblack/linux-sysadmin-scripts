#!/usr/bin/env bash

update_ubuntu () 
{ 
    sudo apt update -y || return 1
    apt list --upgradable
    sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo aptitude update -y && sudo aptitude upgrade -y && sudo killall snap-store && sudo snap refresh
}

# Source the footer
source bash_footer.template.live

