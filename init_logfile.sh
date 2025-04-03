#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/log_info.sh"
. "$SCRIPT_DIR/log_error.sh"

init_logfile() {
    # init_logfile.sh - Initialize or verify a log file in /var/log
    # Usage:
    #   ./init_logfile.sh /var/log/mytool.log [owner] [group] [mode] [--quiet|--dry-run]

    set -euo pipefail

    # --- Defaults ---
    log_path="${1:-}"
    log_owner="${2:-root}"
    log_group="${3:-adm}"
    log_mode="${4:-0640}"
    quiet_mode="no"
    dry_run="no"

    # --- Parse extra options ---
    for arg in "${@:5}"; do
        case "$arg" in
            --quiet) quiet_mode="yes" ;;
            --dry-run) dry_run="yes" ;;
            *)
                log_error "Unknown option: $arg"
                exit 1
                ;;
        esac
    done

    # --- Check required arg ---
    if [[ -z "$log_path" ]]; then
        log_error "No log file path specified."
        echo "Usage: $0 /var/log/mytool.log [owner] [group] [mode] [--quiet|--dry-run]" >&2
        exit 1
    fi

    # --- Check existence ---
    file_exists="no"
    [[ -e "$log_path" ]] && file_exists="yes"

    # --- Check current ownership/permissions ---
    access_ok="no"
    if [[ "$file_exists" == "yes" ]]; then
        current_owner=$(stat -c %U "$log_path" 2>/dev/null || echo "unknown")
        current_group=$(stat -c %G "$log_path" 2>/dev/null || echo "unknown")
        current_mode=$(stat -c %a "$log_path" 2>/dev/null || echo "0000")

        if [[ "$current_owner" == "$log_owner" && "$current_group" == "$log_group" && "$current_mode" == "${log_mode#0}" ]]; then
            access_ok="yes"
        fi
    fi

    # --- --quiet: exit early if all is good ---
    if [[ "$quiet_mode" == "yes" && "$file_exists" == "yes" && "$access_ok" == "yes" ]]; then
        exit 0
    fi

    # --- Logging actions unless quiet ---
    if [[ "$quiet_mode" != "yes" ]]; then
        log_info "Requested log file: $log_path"
        log_info "Desired ownership : ${log_owner}:${log_group}"
        log_info "Desired permissions: ${log_mode}"
    fi

    # --- Determine sudo usage ---
    SUDO=""
    if [[ "$(id -u)" -ne 0 ]]; then
        [[ "$quiet_mode" != "yes" ]] && log_info "Not running as root. Will use sudo where needed."
        SUDO="sudo"
    fi

    # --- Create file if missing ---
    if [[ "$file_exists" == "no" ]]; then
        [[ "$dry_run" == "yes" ]] && log_info "Would create log file: $log_path" || {
            log_info "Creating log file: $log_path"
            $SUDO touch "$log_path"
        }
    fi

    # --- Set owner/group if incorrect ---
    if [[ "$access_ok" != "yes" ]]; then
        [[ "$dry_run" == "yes" ]] && log_info "Would set owner to $log_owner:$log_group" || {
            log_info "Setting owner to $log_owner:$log_group"
            $SUDO chown "$log_owner:$log_group" "$log_path"
        }

        [[ "$dry_run" == "yes" ]] && log_info "Would set permissions to $log_mode" || {
            log_info "Setting permissions to $log_mode"
            $SUDO chmod "$log_mode" "$log_path"
        }
    fi

    # --- Final Summary ---
    [[ "$quiet_mode" != "yes" ]] && {
        echo -e "\n✔️  Log file ${dry_run:+(dry run) }initialization complete:"
        ls -l "$log_path" 2>/dev/null || echo "File not created yet (dry-run)"
    }
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
