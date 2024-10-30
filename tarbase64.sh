#!/usr/bin/env bash

tarbase64 ()
{
    tar -czvf - "$1" | base64
}

# Source the footer
source bash_footer.template.live

