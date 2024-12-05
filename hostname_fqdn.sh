#!/usr/bin/env bash

hostname_fqdn () 
{ 
    python3 -c 'import socket; fqdn = socket.getfqdn(); print(fqdn)'
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

