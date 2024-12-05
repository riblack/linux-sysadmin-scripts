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
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

