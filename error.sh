#!/usr/bin/env bash

error () 
{ 
    printf 'ERROR: %s\n' "$@" 1>&2
    return 1
}

# Source the footer
source bash_footer.template.live

