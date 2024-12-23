#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source ./check_tool.sh

# Function to check and display results for each category
check_if_port_test_tools_are_installed ()
{
    # Declare tools by categories
    declare -A categories
    categories=(
        ["Port Scanning"]="nmap masscan zmap pscan"
        ["Connectivity"]="netcat nc telnet ss lsof hping3"
        ["Packet Analysis"]="tcpdump wireshark tshark"
        ["HTTP/HTTPS"]="curl wget openssl"
        ["Bandwidth Testing"]="iperf iperf3"
        ["Firewall Management"]="ufw firewalld fwknop knockd"
        ["Specialized"]="socat bpftrace"
    )

    for category in "${!categories[@]}"; do
        echo "Category: $category"
        for tool in ${categories[$category]}; do
            check_tool "$tool"
        done
        echo
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

