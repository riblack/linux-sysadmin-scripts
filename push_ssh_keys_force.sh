#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

push_ssh_keys_force ()
{
    while read sys 0<&3; do 
        echo; 
        echo "===== $sys ====="; 
        # push my default key (don't really need the -f on this one)
        \ssh-copy-id -f $sys

        # push sysadmin1's pub key (-f is needed because I don't have his private key)
        \ssh-copy-id -f -i ~/.ssh/sysadmin1_laptop.pub $sys

        # push sysadmin2's pub key (-f is needed because I don't have his private key)
        \ssh-copy-id -f -i ~/.ssh/sysadmin2_laptop.pub $sys

        # push sysadmin3's pub key (-f is needed because I don't have his private key)
        \ssh-copy-id -f -i ~/.ssh/sysadmin3_laptop.pub $sys

    done 3< <(grep -oP '^ *HostName \K.*' ~/.ssh/config | grep .)
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

