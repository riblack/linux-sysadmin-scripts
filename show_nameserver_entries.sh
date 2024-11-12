#!/usr/bin/env bash

show_nameserver_entries ()
{
    nmcli device show | grep IP4.DNS
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

