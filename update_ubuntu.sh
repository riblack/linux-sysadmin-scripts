#!/usr/bin/env bash

unset -f update_ubuntu
update_ubuntu () 
{ 
    sudo apt update -y || return 1;
    apt list --upgradable;
    sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo aptitude update -y && sudo aptitude upgrade -y && sudo killall snap-store && sudo snap refresh
}
update_ubuntu "$@"

