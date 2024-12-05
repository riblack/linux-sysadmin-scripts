#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

whereami () 
{ 

    python3 -c 'import socket; fqdn = socket.getfqdn(); print(fqdn)'
    python3 -c 'import os; hostname = os.uname().nodename; print(hostname)'

    hostname
    hostname -s
    hostname -f

    dig "$HOSTNAME" -t any +noall +answer
    dig "$HOSTNAME" +search -t any +noall +answer

    echo "$HOSTNAME"

    IP_ADDRESS=$( python3 -c 'import socket

    def get_local_ip():
        try:
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            return local_ip
        except Exception:
            return "Unable to get IP address"

    print(get_local_ip())'
    )

    echo "${IP_ADDRESS}"

    dig -x "${IP_ADDRESS}" +noall +answer

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

