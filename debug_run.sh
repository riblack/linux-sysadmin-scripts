#!/usr/bin/env bash

# Debug function to run debug commands only when debug mode is enabled
debug_run ()
{
    if [ "${DEBUG_MODE:=0}" -eq 1 ]; then
        "$@"
    fi
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

