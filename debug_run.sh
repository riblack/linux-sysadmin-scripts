#!/usr/bin/env bash

# Debug function to run debug commands only when debug mode is enabled
debug_run ()
{
    if [ "${DEBUG_MODE:=0}" -eq 1 ]; then
        "$@"
    fi
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

