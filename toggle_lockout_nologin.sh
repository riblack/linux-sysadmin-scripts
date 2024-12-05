#!/usr/bin/env bash

toggle_lockout_nologin ()
{

NOLOGIN_FILE="/etc/nologin"
DEFAULT_MESSAGE="System maintenance in progress. Please try again later."

# Display the help menu
show_help() {
    echo "Usage: $0 [options] [message]"
    echo ""
    echo "Options:"
    echo "  --set [message]    Set nologin with an optional message. Defaults to a canned message if none provided."
    echo "  --remove           Remove nologin if it is set."
    echo "  --toggle           Toggle nologin. If set, it removes it; if not set, it sets it with an optional message."
    echo "  --force            Proceed without confirmation."
    echo "  -h, --help         Display this help message."
    echo ""
    echo "If no options are provided, the script defaults to --toggle."
    echo "If only a message is provided, it defaults to setting nologin with that message."
    exit 0
}

# Display the current state
display_state() {
    if [ -e "$NOLOGIN_FILE" ]; then
        echo "Current state: nologin is SET."
    else
        echo "Current state: nologin is NOT SET."
    fi
}

# Set nologin with a message
set_nologin() {
    local message="${1:-$DEFAULT_MESSAGE}"
    echo "$message" | sudo tee "$NOLOGIN_FILE" > /dev/null
    echo "Ending state: nologin has been SET with message: \"$message\""
}

# Remove nologin
remove_nologin() {
    sudo rm -f "$NOLOGIN_FILE"
    echo "Ending state: nologin has been REMOVED."
}

# Toggle nologin
toggle_nologin() {
    if [ -e "$NOLOGIN_FILE" ]; then
        remove_nologin
    else
        set_nologin "$1"
    fi
}

# Main script function with confirmation option
main() {
    local force=0
    local action=""
    local message=""

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --set) action="set"; message="$2"; shift ;;
            --remove) action="remove" ;;
            --toggle) action="toggle" ;;
            --force) force=1 ;;
            -h|--help) show_help ;;
            *) message="$1" ;;  # Assume any extra input is a message
        esac
        shift
    done

    # Determine default action
    if [[ -z "$action" ]]; then
        if [[ -n "$message" ]]; then
            action="set"
        else
            action="toggle"
        fi
    fi

    # Show current state
    display_state

    # Confirmation unless --force is used
    if [ "$force" -eq 0 ]; then
        read -p "Are you sure you want to proceed with action '$action'? (y/n): " confirm
        if [[ "$confirm" != [yY] ]]; then
            echo "Operation canceled."
            exit 0
        fi
    fi

    # Execute action based on the selected option
    case "$action" in
        set) set_nologin "$message" ;;
        remove) remove_nologin ;;
        toggle) toggle_nologin "$message" ;;
        *) echo "No valid action specified. Use --set, --remove, or --toggle."; exit 1 ;;
    esac
}

# Run main function
main "$@"

}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

