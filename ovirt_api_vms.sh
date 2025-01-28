#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/debug.sh"
. "$SCRIPT_DIR/requires.sh"
. "$SCRIPT_DIR/grab_certificate.sh"
. "$SCRIPT_DIR/NOTES.sh"

NOTES oVirt Version 4.5.6-1.el8
NOTES OVIRT_HOSTNAME="<FQDN>"
NOTES OVIRT_URL="https://$OVIRT_HOSTNAME/ovirt-engine"
NOTES OVIRT_USERNAME="<username>@internalsso"

# Function to interact with oVirt API
ovirt_api_vms() {
    # Check for 'jq' command, package name is also 'jq' in this case
    requires jq jq || return 1

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

    # Prompt for oVirt details if not already set
    OVIRT_HOSTNAME="${OVIRT_HOSTNAME:-}"
    OVIRT_URL="${OVIRT_URL:-}"
    OVIRT_USERNAME="${OVIRT_USERNAME:-}"

    if [ -z "${OVIRT_HOSTNAME}" ]; then
        read -p "Which hostname for the oVirt manager? " OVIRT_HOSTNAME
        export OVIRT_HOSTNAME
    fi

    if [ -z "${OVIRT_URL}" ]; then
        read -p "Which URL for the oVirt manager? " OVIRT_URL
        export OVIRT_URL
    fi

    if [ -z "${OVIRT_USERNAME}" ]; then
        read -e -p "Which OVIRT_USERNAME to use for the oVirt manager? " -i "root" OVIRT_USERNAME
        export OVIRT_USERNAME
    fi

    # Get oVirt password if not already set
    if [[ -z "$OVIRT_PASSWORD" ]]; then
        read -s -p "Enter oVirt password for user $OVIRT_USERNAME: " OVIRT_PASSWORD
        echo
        export OVIRT_PASSWORD
    else
        echo "oVirt password for $OVIRT_USERNAME is already set."
    fi

    # Grab the certificate if not already present
    local cert_file="ovirt-manager.pem"
    grab_certificate "$cert_file" "$OVIRT_HOSTNAME" || return 1

    # CURL configuration
    local curl_args='-s -k'

    # Obtain OAuth token
    echo "Obtaining OAuth token..."
    local response
    response=$(curl $curl_args -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Accept: application/json" \
        --data-urlencode "grant_type=password" \
        --data-urlencode "scope=ovirt-app-api" \
        --data-urlencode "username=$OVIRT_USERNAME" \
        --data-urlencode "password=$OVIRT_PASSWORD" \
        --cacert "$cert_file" \
        "$OVIRT_URL/sso/oauth/token")

    debug echo "========================= show response scope - begin"
    debug jq '.scope' <<<"$response"
    debug echo "========================= show response scope - end"

    # Check if the curl command succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to connect to oVirt API."
        return 1
    fi

    # Extract the token from the response
    local token
    token=$(echo "$response" | jq -r '.access_token')

    if [[ "$token" == "null" || -z "$token" ]]; then
        echo "Failed to obtain OAuth token. Response: $response"
        return 1
    fi

    echo "OAuth token obtained successfully."

    debug echo "============================== received token - begin"
    debug echo "$token"
    debug echo "============================== received token - end"

    # Fetch the list of VMs
    echo "Fetching VM list..."
    local vms
    vms=$(curl $curl_args -X GET \
        -H "Accept: application/xml" \
        -H "Authorization: Bearer $token" \
        --cacert "$cert_file" \
        "$OVIRT_URL/api/vms?all_content=true")

    # Check if the curl command succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to fetch the VM list from oVirt API."
        return 1
    fi

    # Display the VM list
    if [[ -n "$vms" ]]; then
        echo "VM List Response:"
        echo "$vms"
    else
        echo "No VMs found or failed to fetch the VM list."
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

