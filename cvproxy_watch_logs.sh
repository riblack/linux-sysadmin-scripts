#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cvproxy_watch_logs ()
{
    local GLOBAL_CONFIG="/etc/lss.conf"
    local USER_CONFIG="$HOME/.config/lss/lss.conf"

    # Load global configuration if it exists
    if [ -f "$GLOBAL_CONFIG" ]; then
        source "$GLOBAL_CONFIG"
    fi

    # Load user configuration if it exists (overrides global)
    if [ -f "$USER_CONFIG" ]; then
        source "$USER_CONFIG"
    fi

    CVPROXY_HOSTNAME="${CVPROXY_HOSTNAME:-}"
    CVPROXY_USERNAME="${CVPROXY_USERNAME:-}"

    if [ -z "${CVPROXY_HOSTNAME}" ]; then
        read -p "Which hostname is the Commvault proxy? " CVPROXY_HOSTNAME
        export CVPROXY_HOSTNAME
    fi

    if [ -z "${CVPROXY_USERNAME}" ]; then
        read -e -p "Which username to use for Commvault proxy? " -i "root" CVPROXY_USERNAME
        export CVPROXY_USERNAME
    fi

    \ssh ${CVPROXY_USERNAME}@${CVPROXY_HOSTNAME} 'cd /var/log/commvault/Log_Files; tail -F $(ls *.log | grep -v PerformanceMetrics.log)'

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

