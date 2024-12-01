#!/usr/bin/env bash

hostname_short () 
{ 
    python3 -c 'import os; hostname = os.uname().nodename; print(hostname)'
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

