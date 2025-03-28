#!/bin/bash

# Color codes
GREEN="\e[1;32m"
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
RESET="\e[0m"

detect_environment() {
    local virt=""
    local container=""

    # --- Check for container environments first ---
    if grep -qa 'docker\|lxc\|containerd' /proc/1/cgroup; then
        if grep -qa 'docker' /proc/1/cgroup || [ -f /.dockerenv ]; then
            echo -e "${YELLOW}Running inside a Docker container${RESET}"
            return
        elif grep -qa 'lxc' /proc/1/cgroup || grep -qa 'container=lxc' /proc/1/environ; then
            echo -e "${YELLOW}Running inside an LXC container${RESET}"
            return
        fi
    fi

    if [ -f /run/systemd/container ]; then
        container_type=$(cat /run/systemd/container)
        echo -e "${YELLOW}Running inside a container: $container_type${RESET}"
        return
    fi

    # --- Check for systemd-detect-virt if available ---
    if command -v systemd-detect-virt &>/dev/null; then
        virt=$(systemd-detect-virt)
        case "$virt" in
            "none")
                echo -e "${GREEN}Physical machine${RESET}"
                return
                ;;
            "kvm" | "qemu")
                echo -e "${BLUE}Virtual machine: KVM/QEMU${RESET}"
                return
                ;;
            "vmware")
                echo -e "${BLUE}Virtual machine: VMware ESXi${RESET}"
                return
                ;;
            "oracle")
                echo -e "${BLUE}Virtual machine: Oracle VirtualBox${RESET}"
                return
                ;;
            "microsoft")
                echo -e "${BLUE}Virtual machine: Microsoft Hyper-V${RESET}"
                return
                ;;
            "xen")
                echo -e "${BLUE}Virtual machine: Xen${RESET}"
                return
                ;;
            "lxc" | "lxc-libvirt")
                echo -e "${YELLOW}Running inside an LXC container${RESET}"
                return
                ;;
            "docker")
                echo -e "${YELLOW}Running inside a Docker container${RESET}"
                return
                ;;
            *)
                echo -e "${BLUE}Virtual/Container detected: $virt${RESET}"
                return
                ;;
        esac
    fi

    # --- Fallback: Use dmidecode for VM detection ---
    if command -v dmidecode &>/dev/null; then
        sys_manuf=$(sudo dmidecode -s system-manufacturer 2>/dev/null)
        sys_product=$(sudo dmidecode -s system-product-name 2>/dev/null)

        case "$sys_manuf $sys_product" in
            *"VMware"*)
                echo -e "${BLUE}Virtual machine: VMware ESXi${RESET}"
                return
                ;;
            *"Red Hat"*"oVirt"*)
                echo -e "${BLUE}Virtual machine: oVirt/KVM${RESET}"
                return
                ;;
            *"Microsoft Corporation"*)
                echo -e "${BLUE}Virtual machine: Microsoft Hyper-V${RESET}"
                return
                ;;
            *"QEMU"*)
                echo -e "${BLUE}Virtual machine: QEMU/KVM${RESET}"
                return
                ;;
            *"Xen"*)
                echo -e "${BLUE}Virtual machine: Xen${RESET}"
                return
                ;;
            *"Bochs"*)
                echo -e "${BLUE}Virtual machine: Bochs${RESET}"
                return
                ;;
            *)
                echo -e "${GREEN}Physical machine${RESET}"
                return
                ;;
        esac
    fi

    echo -e "${RED}Unable to determine environment${RESET}"
}

detect_environment
