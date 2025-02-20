#!/bin/bash

set -euo pipefail  # Exit on errors, unset variables, and pipe failures

# Required packages: createrepo-c, rsync, apache2
# Install them with: apt install createrepo-c rsync apache2

MIRROR_BASE="/var/www/html/mirrors"
CENTOS_VERSION="8-stream"
CENTOS_MIRROR="rsync://archive.kernel.org/centos-vault/$CENTOS_VERSION"
ISOFILE="$MIRROR_BASE/isos/CentOS-Stream-8-20240603.0-x86_64-dvd1.iso"
ISODIR="/mnt/iso_CentOS-Stream-8-20240603.0-x86_64-dvd1"
OSDIR="$MIRROR_BASE/centos-vault/$CENTOS_VERSION/BaseOS/x86_64/os"
RSYNC_FLAGS="-avz --update --progress"

# Create base directories if they don’t exist
mkdir -p "$MIRROR_BASE/isos" "$OSDIR"

# Rsync repository content
for repo in BaseOS core extras; do
    source="$CENTOS_MIRROR/$repo/x86_64"
    dest="$MIRROR_BASE/centos-vault/$CENTOS_VERSION/$repo/x86_64"
    mkdir -p "$dest"
    rsync $RSYNC_FLAGS "$source/" "$dest/"
done

# Function to safely unmount ISODIR
unmount_iso() {
    if mount | grep -q "$ISODIR"; then
        umount "$ISODIR"
    fi
}

# Mount and sync ISO content
[ -d "$ISODIR" ] || mkdir -p "$ISODIR"
unmount_iso
mount -t iso9660 -o loop,ro "$ISOFILE" "$ISODIR"
rsync $RSYNC_FLAGS --exclude=AppStream/ "$ISODIR/" "$OSDIR/"
rsync $RSYNC_FLAGS "$ISODIR/AppStream/" "$MIRROR_BASE/centos-vault/$CENTOS_VERSION/AppStream/"
unmount_iso

find "$MIRROR_BASE/centos-vault/" -type d -name "x86_64" -exec createrepo_c --update {} \;

repodir="$MIRROR_BASE/centos-vault/$CENTOS_VERSION/AppStream/Packages"
createrepo_c --update "$repodir/"

