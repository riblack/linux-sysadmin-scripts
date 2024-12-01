#!/usr/bin/env bash

toggle_nologin () 
{ 

    # Usage: ./toggle_nologin.sh [on|off]

    case "$1" in
        on)
            echo "Enabling maintenance mode (nologin)..."
            sudo touch /etc/nologin
            echo "Maintenance mode enabled. No non-root users can log in."
            echo "You can control the message displayed through /etc/nologin.txt"
            ;;
        off)
            echo "Disabling maintenance mode (nologin)..."
            sudo rm -f /etc/nologin
            echo "Maintenance mode disabled. Users can log in again."
            ;;
        *)
            echo "Usage: $0 [on|off]"
            exit 1
            ;;
    esac
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

