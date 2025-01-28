#!/usr/bin/env bash
# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check for required dependencies and install if missing
requires() {
    local command="$1"
    local package="${2:-$command}" # Default package name to the command name if not provided

    if ! command -v "$command" &> /dev/null; then
        echo "Error: Required command '$command' is not installed." >&2
        read -p "Would you like to install '$package'? [y/N]: " install_choice
        case "$install_choice" in
            [Yy]*)
                if command -v apt-get &> /dev/null; then
                    sudo apt-get update && sudo apt-get install -y "$package"
                elif command -v yum &> /dev/null; then
                    sudo yum install -y "$package"
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y "$package"
                elif command -v pkg &> /dev/null; then
                    sudo pkg install -y "$package"
                else
                    echo "Error: Unsupported package manager. Please install '$package' manually." >&2
                    return 1
                fi
                ;;
            *)
                echo "Aborted: '$command' is required but not installed." >&2
                return 1
                ;;
        esac
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

