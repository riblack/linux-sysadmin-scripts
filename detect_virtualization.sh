#!/bin/bash

# Color codes
GREEN="\e[1;32m"
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
RESET="\e[0m"

detect_environment() {
    local virt=""
    local virt_type=""

    # --- Check for container environments first ---
    if grep -qa 'docker\|lxc\|containerd' /proc/1/cgroup; then
        if grep -qa 'docker' /proc/1/cgroup || [ -f /.dockerenv ]; then
            echo -e "${YELLOW}Running inside a Docker container${RESET}"
            echo "TYPE=container:docker"
            return
        elif grep -qa 'lxc' /proc/1/cgroup || grep -qa 'container=lxc' /proc/1/environ; then
            echo -e "${YELLOW}Running inside an LXC container${RESET}"
            echo "TYPE=container:lxc"
            return
        fi
    fi

    if [ -f /run/systemd/container ]; then
        virt_type=$(cat /run/systemd/container)
        echo -e "${YELLOW}Running inside a container: $virt_type${RESET}"
        echo "TYPE=container:$virt_type"
        return
    fi

    # --- Check for systemd-detect-virt ---
    if command -v systemd-detect-virt &>/dev/null; then
        virt=$(systemd-detect-virt)
        case "$virt" in
            "none")
                echo -e "${GREEN}Physical machine${RESET}"
                echo "TYPE=physical"
                return
                ;;
            "kvm" | "qemu")
                echo -e "${BLUE}Virtual machine: KVM/QEMU${RESET}"
                echo "TYPE=virtual:kvm"
                return
                ;;
            "vmware")
                echo -e "${BLUE}Virtual machine: VMware ESXi${RESET}"
                echo "TYPE=virtual:vmware"
                return
                ;;
            "oracle")
                echo -e "${BLUE}Virtual machine: Oracle VirtualBox${RESET}"
                echo "TYPE=virtual:virtualbox"
                return
                ;;
            "microsoft")
                echo -e "${BLUE}Virtual machine: Microsoft Hyper-V${RESET}"
                echo "TYPE=virtual:hyperv"
                return
                ;;
            "xen")
                echo -e "${BLUE}Virtual machine: Xen${RESET}"
                echo "TYPE=virtual:xen"
                return
                ;;
            "lxc" | "lxc-libvirt")
                echo -e "${YELLOW}Running inside an LXC container${RESET}"
                echo "TYPE=container:lxc"
                return
                ;;
            "docker")
                echo -e "${YELLOW}Running inside a Docker container${RESET}"
                echo "TYPE=container:docker"
                return
                ;;
            *)
                echo -e "${BLUE}Virtual/Container detected: $virt${RESET}"
                echo "TYPE=virtual:$virt"
                return
                ;;
        esac
    fi

    # --- Fallback: dmidecode detection ---
    if command -v dmidecode &>/dev/null; then
        local sys_manuf
        local sys_product
        sys_manuf=$(sudo dmidecode -s system-manufacturer 2>/dev/null)
        sys_product=$(sudo dmidecode -s system-product-name 2>/dev/null)

        case "$sys_manuf $sys_product" in
            *"VMware"*)
                echo -e "${BLUE}Virtual machine: VMware ESXi${RESET}"
                echo "TYPE=virtual:vmware"
                return
                ;;
            *"Microsoft Corporation"*)
                echo -e "${BLUE}Virtual machine: Microsoft Hyper-V${RESET}"
                echo "TYPE=virtual:hyperv"
                return
                ;;
            *"QEMU"*)
                echo -e "${BLUE}Virtual machine: QEMU/KVM${RESET}"
                echo "TYPE=virtual:kvm"
                return
                ;;
            *"Xen"*)
                echo -e "${BLUE}Virtual machine: Xen${RESET}"
                echo "TYPE=virtual:xen"
                return
                ;;
            *"Bochs"*)
                echo -e "${BLUE}Virtual machine: Bochs${RESET}"
                echo "TYPE=virtual:bochs"
                return
                ;;
        esac

        # More flexible fallback match
        if echo "$sys_manuf $sys_product" | grep -qiE 'ovirt|red hat'; then
            echo -e "${BLUE}Virtual machine: oVirt/KVM${RESET}"
            echo "TYPE=virtual:ovirt"
            return
        fi

        # Bonus: scan full dmidecode output for known virt strings
        local dmidata
        dmidata=$(sudo dmidecode 2>/dev/null)
        if echo "$dmidata" | grep -qiE 'oVirt|KVM|QEMU'; then
            echo -e "${BLUE}Virtual machine: Detected via full DMI scan${RESET}"
            echo "TYPE=virtual:ovirt"
            return
        fi

        echo -e "${GREEN}Physical machine${RESET}"
        echo "TYPE=physical"
        return
    fi

    echo -e "${RED}Unable to determine environment${RESET}"
    echo "TYPE=unknown"
}

detect_environment
