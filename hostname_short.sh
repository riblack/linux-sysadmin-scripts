#!/usr/bin/env bash

hostname_short () 
{ 
    python3 -c 'import os; hostname = os.uname().nodename; print(hostname)'
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

