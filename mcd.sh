#!/usr/bin/env bash

mcd () 
{ 
    mkdir -p "$1"
    cd "$1"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

