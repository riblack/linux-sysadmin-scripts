#!/usr/bin/env bash

show_chrony_status ()
{
    dpkg -l chrony
    sudo systemctl status chrony
    cat -n /etc/chrony/chrony.conf | less
    chronyc tracking
    chronyc sources
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

