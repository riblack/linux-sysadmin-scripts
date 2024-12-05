#!/usr/bin/env bash

mcd () 
{ 
    mkdir -p "$1"
    cd "$1"
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

