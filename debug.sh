#!/usr/bin/env bash

# Debug function to display debug messages only when debug mode is enabled
debug ()
{
    if [ "$DEBUG_MODE" -eq 1 ]; then
        echo "DEBUG: $@" 1>&2
    fi
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

