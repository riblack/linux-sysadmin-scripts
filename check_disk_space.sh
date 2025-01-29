#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/debug.sh"

check_disk_space ()
{
    local target_dir=""
    local min_space_raw=""

    # Usage message
    usage ()
{
        echo "Usage: check_disk_space [-d] <directory> <size_threshold>"
        echo "Options:"
        echo "  -d, --debug       Enable debug mode."
        echo "  -h, --help        Show this help message."
        echo "Examples:"
        echo "  check_disk_space /opt/tmp/Unix 4.5GB"
        echo "  check_disk_space -d /var/logs 500MB"
    }

    # Argument parsing
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--help) usage ;;
            -d|--debug) DEBUG_MODE=1; shift ;;
            *)
                if [[ -z "$target_dir" ]]; then
                    target_dir="$1"
                elif [[ -z "$min_space_raw" ]]; then
                    min_space_raw="$1"
                else
                    echo "ERROR: Too many arguments provided." >&2
                    usage
                fi
                shift
                ;;
        esac
    done

    # Validate input parameters
    if [[ -z "$target_dir" || -z "$min_space_raw" ]]; then
        echo "ERROR: Missing required arguments." >&2
        usage
        return 1
    fi

    # Convert size to kilobytes, handling floating-point values
    local min_space_kb
    case "$min_space_raw" in
        *TB) min_space_kb=$(awk "BEGIN {printf \"%.0f\", ${min_space_raw%TB} * 1024 * 1024 * 1024}") ;;
        *GB) min_space_kb=$(awk "BEGIN {printf \"%.0f\", ${min_space_raw%GB} * 1024 * 1024}") ;;
        *MB) min_space_kb=$(awk "BEGIN {printf \"%.0f\", ${min_space_raw%MB} * 1024}") ;;
        *KB) min_space_kb=$(awk "BEGIN {printf \"%.0f\", ${min_space_raw%KB} }") ;;
        *B)  min_space_kb=$(awk "BEGIN {printf \"%.0f\", ${min_space_raw%B} / 1024}") ;;
        *)
            echo "ERROR: Invalid size format. Use B, KB, MB, GB, or TB (e.g., 4.5GB)." >&2
            return 1
            ;;
    esac

    debug echo "Checking if available disk space in '$target_dir' is above ${min_space_raw} (converted to ${min_space_kb} KB)..."

    # Get available space in KB
    local available_kb
    available_kb=$(df --output=avail "$target_dir" 2>/dev/null | tail -n 1 | tr -d ' ')

    # Validate output
    if [[ -z "$available_kb" || ! "$available_kb" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Unable to determine free disk space in '$target_dir'." >&2
        return 1
    fi

    # Compare space
    if (( available_kb >= min_space_kb )); then
        echo "SUCCESS: Sufficient free disk space in '$target_dir' (${available_kb} KB available, required: ${min_space_kb} KB)."
        return 0
    else
        echo "FAILURE: Insufficient disk space in '$target_dir' (${available_kb} KB available, required: ${min_space_kb} KB)." >&2
        return 1
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

