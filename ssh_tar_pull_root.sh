#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ssh_tar_pull_root ()
{
    local systems=() entries=() start_path="" remote_user="root" save_tgz=false
    local timestamp=$(date +"%Y_%m_%d_%H_%M_%S")
    local base_dir="./$timestamp"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --systems|-s)
                shift
                IFS=',' read -ra systems <<< "$1" # Comma-separated systems
                ;;
            --entries|-e)
                shift
                IFS=',' read -ra entries <<< "$1" # Comma-separated files/directories
                ;;
            --start-path|-p)
                start_path="$2"
                shift
                ;;
            --user|-u)
                remote_user="$2"
                shift
                ;;
            --save-tgz)
                save_tgz=true
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done

    # Validate inputs
    if [[ ${#systems[@]} -eq 0 || ${#entries[@]} -eq 0 ]]; then
        echo "Usage: transfer_and_extract --systems <host1,host2,...> --entries <file1,dir1,...> [--start-path <path>] [--user <user>] [--save-tgz]"
        return 1
    fi

    # Loop through systems
    for system in "${systems[@]}"; do
        echo "Processing system: $system"

        # Prepare system-specific output directory
        local system_dir="$base_dir/$system/$remote_user"
        mkdir -p "$system_dir"

        # Loop through entries
        for entry in "${entries[@]}"; do
            echo "  Transferring and extracting: $entry"

            # Prepare entry-specific output directory
            local entry_start_path=$(ssh "$system" "realpath \"$start_path\"" 2>/dev/null || echo "$start_path")
            local output_dir="$system_dir/${entry_start_path#/}"
            mkdir -p "$output_dir"

            # Construct tar command with optional start path
            local remote_tar_cmd="tar -czvf -"
            [[ -n $start_path ]] && remote_tar_cmd="tar -C \"$start_path\" -czvf -"

            # Generate a proper name for the .tgz file
            local safe_start_path=${entry_start_path#/}
            safe_start_path=${safe_start_path//\//_} # Replace slashes with underscores
            local tgz_name="$output_dir/${timestamp}_${system}_${remote_user}_${safe_start_path}.tgz"

            # Run the SSH and tar commands
            if $save_tgz; then
                ssh "$system" "sudo -u $remote_user bash -c \"$remote_tar_cmd $entry\"" > "$tgz_name"
                echo "  Saved tar stream as: $tgz_name"
            else
                ssh "$system" "sudo -u $remote_user bash -c \"$remote_tar_cmd $entry\"" | tar -C "$output_dir" -xzvf -
                echo "  Files unpacked to: $output_dir"
            fi
        done
    done
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

