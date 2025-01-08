#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rsync_backup ()
{
    # Default local rsync destination
    local DEFAULT_DIR="/data/backups/rsync_backup/"
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

    # Resolve RSYNC_BACKUP_DIR, default to DEFAULT_DIR
    local RSYNC_BACKUP_DIR="${RSYNC_BACKUP_DIR:-$DEFAULT_DIR}"

    # Remove trailing slash from RSYNC_BACKUP_DIR and re-add a single slash
    RSYNC_BACKUP_DIR="${RSYNC_BACKUP_DIR%/}/"

    # Parse options
    local source_host=""
    local source_user="root"  # Default user
    local source_paths=()

    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -h|--host)
                source_host="$2"
                shift 2
                ;;
            -u|--user)
                source_user="$2"
                shift 2
                ;;
            --help)
                echo "Usage: rsync_backup [-h|--host <host>] [-u|--user <user>] <source_path1> [<source_path2> ...]"
                echo
                echo "Options:"
                echo "  -h, --host <host>        Remote host to backup from (required)."
                echo "  -u, --user <user>        SSH user for remote host (default: root)."
                echo
                echo "Source Paths:"
                echo "  Specify one or more remote source paths to backup."
                echo
                echo "Destination directory resolution:"
                echo "  1. ~/.config/lss/lss.conf (highest precedence)"
                echo "  2. /etc/lss.conf (global config)"
                echo "  3. Default: /data/backups/rsync_backup/"
                return 0
                ;;
            *)
                echo "Error: Unknown option $1"
                return 1
                ;;
        esac
    done

    # Remaining arguments are treated as source paths
    if [ -z "$source_host" ] || [ "$#" -eq 0 ]; then
        echo "Error: Source host and at least one source path are required."
        echo "Use --help for usage details."
        return 1
    fi
    source_paths=("$@")

    # Initialize timestamp and base destination
    local datestamp=$(date +"%Y%m%d_%H%M%S")
    local base_destination="${RSYNC_BACKUP_DIR}${source_host}/${datestamp}"

    echo "Starting backup..."
    echo "Source Host: $source_host"
    echo "Source User: $source_user"
    echo "Base Destination: $base_destination"
    echo "Source Paths: ${source_paths[*]}"
    echo "-----------------------------"

    # Ensure the base destination directory exists
    if ! mkdir -p "$base_destination"; then
        echo "Error: Unable to create base destination directory: $base_destination"
        return 1
    fi

    # Process each source path
    for source_path in "${source_paths[@]}"; do
        local destination_path=""
        echo "Processing source path: $source_path"

        # Ensure trailing slash for directories
        case "$source_path" in
            */)
                echo "Detected trailing slash. Assuming directory."
                ;;
            *)
                # Check if it's a file or directory on the remote host
                local path_type
                path_type=$(ssh "$source_user@$source_host" "[ -d '$source_path' ] && echo 'directory' || ([ -f '$source_path' ] && echo 'file')") || {
                    echo "Error: Unable to determine remote path type for $source_path."
                    continue
                }
                if [ "$path_type" == "directory" ]; then
                    source_path="${source_path%/}/"  # Add trailing slash
                    echo "Source path is a directory. Added trailing slash."
                elif [ "$path_type" == "file" ]; then
                    echo "Source path is a file."
                else
                    echo "Error: $source_path does not exist or is an unsupported type."
                    continue
                fi
                ;;
        esac

        # Determine destination structure
        case "$source_path" in
            /*)
                destination_path="${base_destination}/abs${source_path}"
                ;;
            *)
                destination_path="${base_destination}/rel/${source_path}"
                ;;
        esac

        # Ensure the destination directory exists
        local destination_dir="${destination_path%/*}"
        if ! mkdir -p "$destination_dir"; then
            echo "Error: Unable to create destination directory: $destination_dir"
            continue
        fi

        # Perform rsync
        echo "Running rsync..."
        rsync -e "ssh" -Havx --progress "${source_user}@${source_host}:${source_path}" "${destination_path}" || {
            echo "Error: rsync failed for $source_path."
            continue
        }

        echo "Backup completed for: $source_path -> $destination_path"
        echo "-----------------------------"
    done

    echo "Backup process completed."
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

