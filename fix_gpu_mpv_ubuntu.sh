#!/usr/bin/env bash
#
# install_intel_av1_driver.sh
#
# Checks if the user has an Intel Raptor Lake-P [Iris Xe Graphics] GPU.
# If yes, performs the following steps (with confirmation):
#   1. Backs up a list of currently installed packages to /data/backups/.
#   2. Removes intel-media-va-driver (if installed).
#   3. Updates apt package lists.
#   4. Installs intel-media-va-driver-non-free and vainfo.
#   5. Backs up the new list of installed packages to /data/backups/.
#   6. Creates a diff between "before" and "after" package lists.
#   7. Runs vainfo to verify VA-API support for AV1.

set -e

# 0. Preliminary check: create /data/backups if needed
BACKUP_DIR="/data/backups"
mkdir -p "$BACKUP_DIR"

# 1. Detect GPU
echo "Checking for Intel Raptor Lake-P (Iris Xe) GPU..."
if lspci -k | grep -A2 -i "vga\|display" | grep -q "Raptor Lake-P \[Iris Xe Graphics\]"; then
    echo "Detected Intel Raptor Lake-P (Iris Xe) GPU."

    echo ""
    echo "The script will perform the following steps:"
    echo "  1. Create a backup of your current package list."
    echo "  2. Remove 'intel-media-va-driver' (if installed)."
    echo "  3. 'apt update' to refresh package lists."
    echo "  4. Install 'intel-media-va-driver-non-free' and 'vainfo'."
    echo "  5. Create another backup of your package list afterward."
    echo "  6. Generate a diff of the 'before' and 'after' package lists."
    echo "  7. Run vainfo to confirm VA-API AV1 support."
    echo ""

    read -r -p "Do you want to proceed with these changes? [y/N] " RESP
    case "$RESP" in
        [yY] | [yY][eE][sS])
            # 2. Back up 'before' packages
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            BEFORE_LIST="$BACKUP_DIR/packages_before_$TIMESTAMP.txt"
            AFTER_LIST="$BACKUP_DIR/packages_after_$TIMESTAMP.txt"
            DIFF_FILE="$BACKUP_DIR/packages_diff_$TIMESTAMP.txt"

            echo ""
            echo "Creating a backup of currently installed packages at:"
            echo "  $BEFORE_LIST"
            dpkg -l >"$BEFORE_LIST"

            # 3. Remove old driver (if any), update, and install new packages
            echo ""
            echo "Removing 'intel-media-va-driver' (if installed)..."
            sudo apt -y remove intel-media-va-driver 2>/dev/null || true

            echo ""
            echo "Updating package lists..."
            sudo apt update

            echo ""
            echo "Installing 'intel-media-va-driver-non-free' and 'vainfo'..."
            sudo apt -y install intel-media-va-driver-non-free vainfo

            # 4. Back up 'after' packages
            echo ""
            echo "Creating a backup of newly installed packages at:"
            echo "  $AFTER_LIST"
            dpkg -l >"$AFTER_LIST"

            # 5. Generate diff
            echo ""
            echo "Generating a diff of before/after package lists..."
            diff -u "$BEFORE_LIST" "$AFTER_LIST" >"$DIFF_FILE" || true
            echo "Diff stored in:"
            echo "  $DIFF_FILE"
            echo ""

            # 6. Run vainfo to confirm AV1 support
            echo "Running vainfo to confirm AV1 hardware decode:"
            vainfo
            echo ""
            echo "All steps completed."
            ;;
        *)
            echo "Aborted by user."
            exit 0
            ;;
    esac
else
    echo "Raptor Lake-P [Iris Xe Graphics] not detected on this system."
    exit 0
fi

read -r -p "Do you want to optionally install libva2 and related Mesa packages? [y/N] " RESP
case "$RESP" in
    [yY] | [yY][eE][sS])
        sudo apt update
        sudo apt install libva2 libva-drm2 libva-x11-2 mesa-va-drivers
        ;;
    *)
        echo "Aborted by user."
        exit 0
        ;;
esac

read -r -p "Do you want to optionally install extra codecs (Ubunut's restricted extras and FFmpeg's extra libraries)? [y/N] " RESP
case "$RESP" in
    [yY] | [yY][eE][sS])
        sudo apt update
        sudo apt install ubuntu-restricted-extras libavcodec-extra
        ;;
    *)
        echo "Aborted by user."
        exit 0
        ;;
esac
