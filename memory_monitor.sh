#!/usr/bin/env bash

memory_monitor () 
{
    # Set threshold values (in MB)
    MEMORY_THRESHOLD=500   # Free memory threshold in MB
    SWAP_THRESHOLD=100     # Swap usage threshold in MB

    while true; do
        # Get available memory (in MB)
        available_memory=$(free -m | awk '/^Mem:/{print $7}')
        # Get used swap (in MB)
        used_swap=$(free -m | awk '/^Swap:/{print $3}')

        # Check if available memory is below the threshold
        if (( available_memory < MEMORY_THRESHOLD )); then
            notify-send "Low Memory Alert" "Available memory is below ${MEMORY_THRESHOLD}MB. Currently at ${available_memory}MB."
        fi

        # Check if used swap is above the threshold
        if (( used_swap > SWAP_THRESHOLD )); then
            notify-send "High Swap Usage Alert" "Swap usage is above ${SWAP_THRESHOLD}MB. Currently at ${used_swap}MB."
        fi

        # Sleep for 30 seconds before checking again (adjust as needed)
        sleep 30
    done
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

