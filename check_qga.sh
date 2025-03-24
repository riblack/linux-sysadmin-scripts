#!/bin/bash

set -euo pipefail

# Function to log messages
log() {
  echo "[INFO] $*"
}

# Function to detect oVirt guest
is_ovirt_guest() {
  local product_name sys_vendor

  product_name=$(head -n 1 /sys/class/dmi/id/product_name 2>/dev/null || echo "")
  sys_vendor=$(head -n 1 /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")

  [[ "$product_name" =~ (oVirt|RHEV|Virtual\ Machine|KVM|RHEL) ]] || return 1
  [[ "$sys_vendor" =~ (oVirt|Red\ Hat|QEMU) ]] || return 1

  return 0
}

# Function to install qemu-guest-agent
install_qemu_guest_agent() {
  local pkg_mgr=""

  if command -v apt-get >/dev/null; then
    pkg_mgr="apt"
  elif command -v dnf >/dev/null; then
    pkg_mgr="dnf"
  elif command -v yum >/dev/null; then
    pkg_mgr="yum"
  else
    echo "[ERROR] No supported package manager found (apt, dnf, yum)"
    exit 1
  fi

  if ! command -v qemu-ga >/dev/null; then
    log "qemu-guest-agent not found, attempting to install..."
    if [[ $pkg_mgr == "apt" ]]; then
      sudo apt-get update
      sudo apt-get install -y qemu-guest-agent
    else
      sudo "$pkg_mgr" install -y qemu-guest-agent
    fi
  else
    log "qemu-guest-agent is already installed."
  fi

  # Ensure it's enabled and started
  sudo systemctl enable --now qemu-guest-agent
  log "qemu-guest-agent has been installed and started."
}

# Main logic
main() {
  if is_ovirt_guest; then
    log "System appears to be a guest of oVirt."
    install_qemu_guest_agent
  else
    log "System is not a guest of oVirt. No action taken."
  fi
}

main "$@"

