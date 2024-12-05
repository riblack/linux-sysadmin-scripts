#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

toggle_gnome_screenshot_shutter_sound() {
    local shutter_sound_file="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"
    local disabled_file="${shutter_sound_file}.disabled"
    
    # Check current state
    if [[ -e "$shutter_sound_file" ]]; then
        local current_state="on"
    elif [[ -e "$disabled_file" ]]; then
        local current_state="off"
    else
        echo "Error: Neither $shutter_sound_file nor $disabled_file found."
        return 1
    fi
    
    # Print the current state
    echo "Current state: $current_state"

    # Determine the target state
    case "$1" in
        "on")
            target_state="on"
            ;;
        "off")
            target_state="off"
            ;;
        *)
            # Toggle if no specific command is given
            target_state=$([[ "$current_state" == "on" ]] && echo "off" || echo "on")
            ;;
    esac

    # Apply the target state
    if [[ "$target_state" == "on" && "$current_state" == "off" ]]; then
        sudo mv "$disabled_file" "$shutter_sound_file"
        echo "Shutter sound enabled."
    elif [[ "$target_state" == "off" && "$current_state" == "on" ]]; then
        sudo mv "$shutter_sound_file" "$disabled_file"
        echo "Shutter sound disabled."
    else
        echo "Shutter sound is already $target_state."
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

