#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display usage and exit
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Usage: $(basename "$0")

Validates the Commvault environment by performing the following checks:
  - Required hostnames exist in /etc/hosts
  - Sufficient free space in Commvault directories
  - Correct Commvault gateway configured
  - cvping connectivity to CommServe
  - Commvault systemd service status

The script loads config from the first found of:
  1. /etc/lss.conf
  2. ~/.config/lss/lss.conf
  3. ./lss.conf

Each config file must define the following variables:

Sample lss.conf:
--------------------------------------------------------
COMMVAULT_REQUIRED_HOSTS=(
    "cvlt-server.example.com"
    "hypervisor01.example.com"
    "hypervisor02.example.com"
    "hypervisor03.example.com"
)

COMMVAULT_SERVICE="commvault.Instance001.service"

COMMVAULT_GATEWAY_EXPECTED="cvlt-server.example.com"

COMMVAULT_CVPING_PATH="/opt/commvault/Base64/cvping"
--------------------------------------------------------

Exit codes:
  0 - All checks passed
  1 - One or more checks failed

Requires: sudo privileges

EOF
    exit 0
fi

set -euo pipefail

GLOBAL_CONFIG="/etc/lss.conf"
USER_CONFIG="$HOME/.config/lss/lss.conf"
LOCAL_CONFIG="$SCRIPT_DIR/lss.conf"

# Load configuration files (global → user → local)

if [ -f "$GLOBAL_CONFIG" ]; then
    source "$GLOBAL_CONFIG"
fi

if [ -f "$USER_CONFIG" ]; then
    source "$USER_CONFIG"
fi

if [ -f "$LOCAL_CONFIG" ]; then
    source "$LOCAL_CONFIG"
fi

HOSTS_FILE="/etc/hosts"

COMMVAULT_REQUIRED_HOSTS="${COMMVAULT_REQUIRED_HOSTS:-}"
COMMVAULT_SERVICE="${COMMVAULT_SERVICE:-}"
COMMVAULT_GATEWAY_EXPECTED="${COMMVAULT_GATEWAY_EXPECTED:-}"
COMMVAULT_CVPING_PATH="${COMMVAULT_CVPING_PATH:-}"

# Helper to ensure sudo is available before we do anything else
ensure_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "❌ This script requires sudo privileges. Please run as a user with sudo access."
        exit 1
    fi
}

# Wrapper to run privileged commands
run_as_root() {
    if [[ $EUID -ne 0 ]]; then
        sudo "$@"
    else
        "$@"
    fi
}

check_hosts() {
    echo "Checking /etc/hosts entries..."
    local missing=0
    for entry in "${COMMVAULT_REQUIRED_HOSTS[@]}"; do
        if ! grep -q "$entry" "$HOSTS_FILE"; then
            echo "❌ Missing $entry in $HOSTS_FILE"
            missing=1
        fi
    done
    [[ $missing -eq 0 ]] && echo "✅ All required hosts present."
    return $missing
}

check_df() {
    echo "Checking free space in /opt/tmp/Unix/ and /opt/commvault/ ..."
    local low_space=0
    for path in "/opt/tmp/Unix/" "/opt/commvault/"; do
        if df -Ph "$path" | awk 'NR==2 {gsub(/G/, "", $4); if ($4+0 < 1) exit 1}'; then
            echo "✅ $path has enough space."
        else
            echo "❌ Less than 1G available in $path"
            low_space=1
        fi
    done
    return $low_space
}

check_commvault_status() {
    echo "Checking commvault status..."
    local status_output
    status_output=$(run_as_root commvault status 2>/dev/null)

    if [[ "$status_output" == *"CommServe/Gateway Host Name = $COMMVAULT_GATEWAY_EXPECTED"* ]]; then
        echo "✅ Correct CommServe/Gateway Host Name found."
        return 0
    else
        echo "❌ Incorrect or missing CommServe/Gateway Host Name in commvault status."
        return 1
    fi
}

check_cvping() {
    echo "Pinging CommServe with cvping..."
    if run_as_root "$COMMVAULT_CVPING_PATH" "$COMMVAULT_GATEWAY_EXPECTED" 2>&1 | grep -q "Successfully connected"; then
        echo "✅ cvping successful."
        return 0
    else
        echo "❌ cvping failed."
        return 1
    fi
}

check_systemctl() {
    echo "Checking systemctl status of Commvault service..."
    if systemctl is-active --quiet "$COMMVAULT_SERVICE"; then
        echo "✅ Commvault service is active."
        return 0
    else
        echo "❌ Commvault service is not running."
        return 1
    fi
}

main() {
    echo "=== Starting Commvault Environment Validation ==="
    ensure_sudo

    local fail=0

    check_hosts || fail=1
    check_df || fail=1
    check_commvault_status || fail=1
    check_cvping || fail=1
    check_systemctl || fail=1

    if [[ $fail -eq 0 ]]; then
        echo "🎉 All checks passed successfully!"
    else
        echo "❗ One or more checks failed. Please review the output."
        exit 1
    fi
}

main "$@"
