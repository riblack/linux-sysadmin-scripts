#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

# Function to retrieve network details of a host (local or remote)
net_details.sh.2 ()
{
    local target_host="$1"
    local is_remote=0
    local ssh_cmd=""
    local output

    # Determine if running locally or via SSH
    if [[ -n "$target_host" && "$target_host" != "localhost" && "$target_host" != "$(hostname -f)" ]]; then
        is_remote=1
        ssh_cmd="ssh -T -o BatchMode=yes -o ConnectTimeout=5 $target_host"
    fi

    if [[ "$is_remote" -eq 1 ]]; then
        output=$($ssh_cmd bash <<'EOF'
            fqdn=$(hostname -f 2>/dev/null || hostname)
            ip=$(ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d'/' -f1 | head -n1)
            mac=$(ip link show | awk '/ether/ {print $2; exit}')
            subnet=$(ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d'/' -f2 | head -n1)
            gw=$(ip route | awk '/default/ {print $3; exit}')
            dns=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | tr '\n' ' ')
            rev_dns=$(nslookup $ip 2>/dev/null | awk '/name =/ {print $4}')
            uptime=$(uptime -p)
            latency=$(ping -c 1 -W 1 $fqdn 2>/dev/null | awk -F'=' '/time=/{print $2}' | awk '{print $1 " ms"}')

            echo "$fqdn|$ip|$subnet|$mac|$gw|$dns|$rev_dns|$uptime|$latency"
EOF
        )
    else
        fqdn=$(hostname -f 2>/dev/null || hostname)
        ip=$(ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d'/' -f1 | head -n1)
        mac=$(ip link show | awk '/ether/ {print $2; exit}')
        subnet=$(ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d'/' -f2 | head -n1)
        gw=$(ip route | awk '/default/ {print $3; exit}')
        dns=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | tr '\n' ' ')
        rev_dns=$(nslookup $ip 2>/dev/null | awk '/name =/ {print $4}')
        uptime=$(uptime -p)
        latency=$(ping -c 1 -W 1 $fqdn 2>/dev/null | awk -F'=' '/time=/{print $2}' | awk '{print $1 " ms"}')

        output="$fqdn|$ip|$subnet|$mac|$gw|$dns|$rev_dns|$uptime|$latency"
    fi

    # Parse the output
    IFS='|' read -r fqdn ip subnet mac gw dns rev_dns uptime latency <<< "$output"

    # Output formatted details
    cat <<EOF
-------------------------------------------------
  Host Network Details
-------------------------------------------------
  Hostname    : $fqdn
  IP Addr     : $ip
  Subnet      : /$subnet
  MAC Addr    : $mac
  Gateway     : $gw
  DNS Servers : $dns
  Reverse DNS : ${rev_dns:-N/A}
  Uptime      : $uptime
  Ping Latency: ${latency:-Unreachable}
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

