#!/usr/bin/env bash

hostname_fqdn () 
{ 
    python3 -c 'import socket; fqdn = socket.getfqdn(); print(fqdn)'
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

