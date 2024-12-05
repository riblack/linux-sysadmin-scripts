#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

toggle_sudo_access ()
{

    # Function to show usage information
    usage() {
        echo "Usage: $0 [-u username] [-s on|off]"
        echo "  -u, --user    Specify the username to toggle sudo power."
        echo "  -s, --state   Set sudo state explicitly to 'on' or 'off'."
        echo "If no username is provided, you will be prompted to enter one."
        echo "If no state is specified, the script will toggle the current state."
    }

    # Detect the sudo group at runtime
    if getent group sudo >/dev/null; then
        SUDO_GROUP="sudo"
    elif getent group wheel >/dev/null; then
        SUDO_GROUP="wheel"
    else
        echo "Error: No suitable sudo group found (tried 'sudo' and 'wheel')."
        return 1
    fi

    # Parse command line arguments
    TARGET_USER=""
    DESIRED_STATE=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--user)
                TARGET_USER="$2"
                shift 2
                ;;
            -s|--state)
                DESIRED_STATE="$2"
                if [[ "$DESIRED_STATE" != "on" && "$DESIRED_STATE" != "off" ]]; then
                    echo "Error: --state must be 'on' or 'off'."
                    usage
                    return 1
                fi
                shift 2
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                return 1
                ;;
        esac
    done

    # Prompt for username if not provided
    if [[ -z "$TARGET_USER" ]]; then
        read -p "Enter the username to toggle sudo power: " TARGET_USER
    fi

    # Check if the user exists on the system
    if ! id "$TARGET_USER" &>/dev/null; then
        echo "Error: User '$TARGET_USER' does not exist."
        return 1
    fi

    # Check if the user currently has sudo privileges
    if id -nG "$TARGET_USER" | grep -qw "$SUDO_GROUP"; then
        CURRENT_STATE="on"
    else
        CURRENT_STATE="off"
    fi

    # Display the initial sudo state
    echo "Current sudo state for $TARGET_USER: $CURRENT_STATE"

    # Determine the target state
    if [[ -z "$DESIRED_STATE" ]]; then
        # Toggle if no state was specified
        TARGET_STATE=$([[ "$CURRENT_STATE" == "on" ]] && echo "off" || echo "on")
    else
        TARGET_STATE="$DESIRED_STATE"
    fi

    # Apply the target state
    if [[ "$CURRENT_STATE" != "$TARGET_STATE" ]]; then
        if [[ "$TARGET_STATE" == "on" ]]; then
            sudo usermod -aG "$SUDO_GROUP" "$TARGET_USER"
            echo "Sudo privileges granted to $TARGET_USER."
        else
            sudo gpasswd -d "$TARGET_USER" "$SUDO_GROUP"
            echo "Sudo privileges removed from $TARGET_USER."
        fi
    else
        echo "Sudo state for $TARGET_USER is already set to '$CURRENT_STATE'. No changes needed."
    fi

    # Display the final sudo state
    if id -nG "$TARGET_USER" | grep -qw "$SUDO_GROUP"; then
        FINAL_STATE="on"
    else
        FINAL_STATE="off"
    fi

    echo "Final sudo state for $TARGET_USER: $FINAL_STATE"

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

