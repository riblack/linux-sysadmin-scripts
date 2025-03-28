#!/bin/bash

detect_environment() {
    local virt=""
    local container=""

    # --- Check for container environments first ---
    if grep -qa 'docker\|lxc\|containerd' /proc/1/cgroup; then
        if grep -qa 'docker' /proc/1/cgroup || [ -f /.dockerenv ]; then
            echo "Running inside a Docker container"
            return
        elif grep -qa 'lxc' /proc/1/cgroup || grep -qa 'container=lxc' /proc/1/environ; then
            echo "Running inside an LXC container"
            return
        fi
    fi

    if [ -f /run/systemd/container ]; then
        container_type=$(cat /run/systemd/container)
        echo "Running inside a container: $container_type"
        return
    fi

    # --- Check for systemd-detect-virt if available ---
    if command -v systemd-detect-virt &>/dev/null; then
        virt=$(systemd-detect-virt)
        case "$virt" in
            "none")
                echo "Physical machine"
                return
                ;;
            "kvm"|"qemu")
                echo "Virtual machine: KVM/QEMU"
                return
                ;;
            "vmware")
                echo "Virtual machine: VMware ESXi"
                return
                ;;
            "oracle")
                echo "Virtual machine: Oracle VirtualBox"
                return
                ;;
            "microsoft")
                echo "Virtual machine: Microsoft Hyper-V"
                return
                ;;
            "xen")
                echo "Virtual machine: Xen"
                return
                ;;
            "lxc"|"lxc-libvirt")
                echo "Running inside an LXC container"
                return
                ;;
            "docker")
                echo "Running inside a Docker container"
                return
                ;;
            *)
                echo "Virtual/Container detected: $virt"
                return
                ;;
        esac
    fi

    # --- Fallback: Use dmidecode for virtual machine detection ---
    if command -v dmidecode &>/dev/null; then
        sys_manuf=$(sudo dmidecode -s system-manufacturer 2>/dev/null)
        sys_product=$(sudo dmidecode -s system-product-name 2>/dev/null)

        case "$sys_manuf $sys_product" in
            *"VMware"*)
                echo "Virtual machine: VMware ESXi"
                return
                ;;
            *"Red Hat"*"oVirt"*)
                echo "Virtual machine: oVirt"
                return
                ;;
            *"Microsoft Corporation"*)
                echo "Virtual machine: Microsoft Hyper-V"
                return
                ;;
            *"QEMU"*)
                echo "Virtual machine: QEMU/KVM"
                return
                ;;
            *"Xen"*)
                echo "Virtual machine: Xen"
                return
                ;;
            *"Bochs"*)
                echo "Virtual machine: Bochs"
                return
                ;;
            *)
                echo "Physical machine"
                return
                ;;
        esac
    fi

    echo "Unable to determine environment"
}

detect_environment

