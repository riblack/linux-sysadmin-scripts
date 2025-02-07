#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

# Function to retrieve network details of a host (local or remote)
net_details ()
{
    local target_host="$1"
    local is_remote=0
    local ssh_cmd=""

    # Determine if running locally or via SSH
    if [[ -n "$target_host" && "$target_host" != "localhost" && "$target_host" != "$(hostname -f)" ]]; then
        is_remote=1
        ssh_cmd="ssh -o BatchMode=yes -o ConnectTimeout=5 $target_host"
    fi

    # Function to execute commands locally or remotely
    run_cmd ()
{
        local cmd="$1"
        if [[ "$is_remote" -eq 1 ]]; then
            $ssh_cmd "$cmd"
        else
            eval "$cmd"
        fi
    }

    # Gather data
    local fqdn ip mac subnet gw dns rev_dns uptime latency
    fqdn=$(run_cmd "hostname -f 2>/dev/null || hostname")
    ip=$(run_cmd "ip -4 addr show scope global | awk '/inet / {print \$2}' | cut -d'/' -f1 | head -n1")
    mac=$(run_cmd "ip link show | awk '/ether/ {print \$2; exit}'")
    subnet=$(run_cmd "ip -4 addr show scope global | awk '/inet / {print \$2}' | cut -d'/' -f2 | head -n1")
    gw=$(run_cmd "ip route | awk '/default/ {print \$3; exit}'")
    dns=$(run_cmd "awk '/^nameserver/ {print \$2}' /etc/resolv.conf | tr '\n' ' '")
    rev_dns=$(run_cmd "nslookup $ip 2>/dev/null | awk '/name =/ {print \$4}'")
    uptime=$(run_cmd "uptime -p")
    latency=$(run_cmd "ping -c 1 -W 1 $fqdn 2>/dev/null | awk -F'=' '/time=/{print \$2}' | awk '{print \$1 \" ms\"}'")

    # Output formatted details
    cat <<EOF
-------------------------------------------------
  Host Network Details
-------------------------------------------------
  Hostname  : $fqdn
  IP Addr   : $ip
  Subnet    : /$subnet
  MAC Addr  : $mac
  Gateway   : $gw
  DNS       : $dns
  Reverse DNS : ${rev_dns:-N/A}
  Uptime    : $uptime
  Ping Latency : ${latency:-Unreachable}
-------------------------------------------------
EOF
}

# Usage examples:
# net_details            # Run locally
# net_details remote-host # Run remotely via SSH

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

