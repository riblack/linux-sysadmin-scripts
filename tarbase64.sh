#!/usr/bin/env bash

tarbase64 ()
{
    tar -czvf - "$1" | base64
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

