#!/usr/bin/env bash

error () 
{ 
    # Fields

    # ERROR:
    # Datestamp
    # Hostname
    # Script name
    # Error message

    DATESTAMP_NOW=$(date "+%Y-%m-%d %H:%M:%S %a")

    printf 'ERROR: [%s] [%s] [%s] %s\n' "${DATESTAMP_NOW}" "${HOSTNAME}" "$0" "$@" 1>&2

    return 1
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

