#!/usr/bin/env bash

# Debug function to display debug messages only when debug mode is enabled
debug ()
{
    if [ "${DEBUG_MODE:=0}" -eq 1 ]; then
        echo "DEBUG: $@" 1>&2
    fi
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

