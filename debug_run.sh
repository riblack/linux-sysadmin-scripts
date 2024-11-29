#!/usr/bin/env bash

# Debug function to run debug commands only when debug mode is enabled
debug_run ()
{
    if [ "$DEBUG_MODE" -eq 1 ]; then
        "$@"
    fi
}

# Source the footer
source bash_footer.template.live

