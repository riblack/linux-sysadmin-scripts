#!/usr/bin/env bash

hostname_short () 
{ 
    python3 -c 'import os; hostname = os.uname().nodename; print(hostname)'
}

# Source the footer
source bash_footer.template.live

