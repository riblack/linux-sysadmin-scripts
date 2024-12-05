#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source debug_run.sh
if [ -f "$SCRIPT_DIR/debug_run.sh" ]; then
    . "$SCRIPT_DIR/debug_run.sh"
else
    echo "debug_run.sh is missing. Exiting..."
    exit 1
fi

run_grep_my_homedir () 
{ 
    debug_run set -xv

    SEARCHSTRING="$@"
    sudo grep -r -I -D skip "$SEARCHSTRING" ~

    return_value=$?
    debug_run set +xv
    return $return_value
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

