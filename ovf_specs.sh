#!/bin/bash

set -euo pipefail

ovf_specs() {

    command -v xmllint || sudo apt install libxml2-utils
    command -v xmlstarlet || sudo apt install xmlstarlet

    local ovf="${1:-vm.ovf}"
    [[ ! -f "$ovf" ]] && {
        echo "OVF file '$ovf' not found"
        return 1
    }

    local cleaned="/tmp/cleaned_ovf.xml"
    local strip_xslt="./strip_ns.xslt"
    [[ ! -f "$strip_xslt" ]] && {
        echo "Missing XSLT: $strip_xslt"
        return 1
    }

    xmlstarlet tr "$strip_xslt" "$ovf" >"$cleaned"

    echo "=== VM Specs from: $ovf ==="
    echo

    # CPU & Memory
    echo "CPU & Memory:"
    xmlstarlet sel -t \
        -m "//Item[ResourceType='3']" -v "concat('  Cores: ', VirtualQuantity)" -n \
        -m "//Item[ResourceType='4']" -v "concat('  Memory: ', VirtualQuantity, ' MB')" -n \
        "$cleaned"
    echo

    # NICs
    echo "NIC(s):"
    xmlstarlet sel -t -m "//Item[ResourceType='10']" \
        -v "concat('  - MAC: ', MACAddress, '  Speed: ', speed, ' Mbps')" -n \
        "$cleaned"
    echo

    # Disks
    echo "Disk(s):"
    xmlstarlet sel -t -m "//Disk" \
        -v "concat('  - ID: ', @diskId, ', Size: ', @capacity, ' GiB')" -n \
        "$cleaned"
    echo

    # Display
    echo "Display Adapter:"
    xmlstarlet sel -t -m "//Item[ResourceType='32768']" \
        -v "concat('  - Device: ', Device, '  VRAM: ', SpecParams/vram, ' KB')" -n \
        "$cleaned"
    echo

    # RNG
    echo "RNG Device:"
    xmlstarlet sel -t -m "//Item[Type='rng']" \
        -v "concat('  - Device: ', Device, '  Source: ', SpecParams/source)" -n \
        "$cleaned"
    echo

    # Balloon
    echo "Balloon Device:"
    xmlstarlet sel -t -m "//Item[Device='memballoon']" \
        -v "concat('  - Model: ', SpecParams/model)" -n \
        "$cleaned"
    echo

    # USB
    echo "USB Controller:"
    xmlstarlet sel -t -m "//Item[Device='usb']" \
        -v "concat('  - Alias: ', Alias, '  Model: ', SpecParams/model)" -n \
        "$cleaned"
    echo

    # VirtIO-SCSI
    echo "VirtIO-SCSI Controller:"
    xmlstarlet sel -t -m "//Item[Device='virtio-scsi']" \
        -v "concat('  - Alias: ', Alias, '  IOThreadId: ', SpecParams/ioThreadId)" -n \
        "$cleaned"
    echo
}

ovf_specs "$@"
