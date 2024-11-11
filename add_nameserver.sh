#!/usr/bin/env bash

add_nameserver ()
{

    # Check if the DNS server IP address was provided as a command-line argument
    if [ -z "$1" ]; then
      echo "Usage: $0 <new_dns_server_ip>"
      exit 1
    fi

    # Assign the DNS server IP from the argument
    NEW_DNS="$1"

    # Find the active interface that has the default route
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

    if [ -z "$INTERFACE" ]; then
      echo "No active interface with a default route found."
      exit 1
    fi

    # Get the connection name associated with the active interface
    CONNECTION_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$INTERFACE" | cut -d':' -f1)

    if [ -z "$CONNECTION_NAME" ]; then
      echo "No active NetworkManager connection found for interface $INTERFACE."
      exit 1
    fi

    # Set the new DNS server as the primary nameserver
    nmcli connection modify "$CONNECTION_NAME" ipv4.dns "$NEW_DNS" ipv4.dns-priority 1

    # Restart the connection to apply changes
    nmcli connection down "$CONNECTION_NAME" && nmcli connection up "$CONNECTION_NAME"

    echo "DNS server $NEW_DNS has been set as the primary DNS for connection $CONNECTION_NAME on interface $INTERFACE."

}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

