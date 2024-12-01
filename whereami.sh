#!/usr/bin/env bash

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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

