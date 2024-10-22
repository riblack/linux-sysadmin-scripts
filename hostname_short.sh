#!/usr/bin/env bash

hostname_short () 
{ 
    python3 -c 'import os; hostname = os.uname().nodename; print(hostname)'
}

hostname_short "$@"
