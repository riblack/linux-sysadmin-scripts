#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_chrony_status ()
{
    dpkg -l chrony
    sudo systemctl status chrony
    cat -n /etc/chrony/chrony.conf | less
    chronyc tracking
    chronyc sources
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

