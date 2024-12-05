#!/usr/bin/env bash

show_nameserver_entries ()
{
    nmcli device show | grep IP4.DNS
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

