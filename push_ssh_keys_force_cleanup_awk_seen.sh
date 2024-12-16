#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# You need to monitor the output of mkdir and cp to make sure it is successful.
# Interactively allow you to 
# * make a backup of the authorized_keys file and
# * edit each file to make sure they are uniq

# If you read the vim command below you will notice it is performing the following
# * set number - turn on line numbers inside of vim (set nonu to turn off)
# * set hls - turn on highlighting so the search will stand out
# * match Search /[^ ]*$/ - search for the user@host descriptor which is at the end of each line
# * %!awk '\!seen[\$0]++' - make sure the lines are uniq

# Yeah this can use some cleanup, but it is what it is for now

# Use undo and redo to see what changes this script performed
# u - undo
# ctrl+r redo

# Manual commands if you need them
# set nu - turn on line numbers
# set nonu - turn off line numbers
# set hls - turn on highlighting for when you search
# set nohls
# / [^ ]*$ - search for the user@host descriptors at the end of each line
# %!awk '\!seen[$0]++' - uniq the lines

push_ssh_keys_force_cleanup_awk_seen ()
{
    cmd=$( cat <<'EOF'
        mkdir -p /data/backups
        file=~/.ssh/authorized_keys
        file_short=${file##*/}
        bak="/data/backups/${file_short}_$(stat -c "%Y" "$file")_$(date +"%s").bak"
        cp -avi "$file" "$bak"
        ls -ld "$bak"
        read -p "Backup made, see above. Press enter when ready to continue"
        # Check if vim is available, fallback to vi otherwise
        editor=$(command -v vim || command -v vi)
        $editor -c "set number | set hls | match Search /[^ ]*$/ | %!awk '\!seen[\$0]++'" ~/.ssh/authorized_keys
EOF
)
    while read -r system 0<&3; do
        echo
        echo "===== $system ====="
        read -p "Press ENTER to begin sleeping for 2 seconds"
        sleep 2
        \ssh -t $system "$cmd"
    done 3< <(grep -oP '^ *HostName \K.*' ~/.ssh/config | grep .)
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

