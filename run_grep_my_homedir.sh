#!/usr/bin/env bash

. debug_run.sh

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
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

