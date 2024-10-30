#!/usr/bin/env bash

mcd () 
{ 
    mkdir -p "$1"
    cd "$1"
}

# Source the footer
source bash_footer.template.live

