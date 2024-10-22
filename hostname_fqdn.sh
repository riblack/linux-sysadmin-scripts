#!/usr/bin/env bash

hostname_fqdn () 
{ 
    python3 -c 'import socket; fqdn = socket.getfqdn(); print(fqdn)'
}

hostname_fqdn "$@"
