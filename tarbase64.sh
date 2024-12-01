#!/usr/bin/env bash

tarbase64 ()
{
    tar -czvf - "$1" | base64
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

