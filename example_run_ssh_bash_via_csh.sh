#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

example_run_ssh_bash_via_csh ()
{
    # Your target host that has csh as the default shell
    csh_host=$1

    # Commands to run on the target host
    cmd=$(cat <<'EOF' | base64 -w 0
        testing_function ()
        {
            echo "This should reflect bash: $0"
            hostname;
            uptime
        }
        testing_function 
EOF
)

    # echo $cmd | base64 -d | xxd -g 1

    # Run the commands on the target host
    \ssh $csh_host "echo Remote shell is: \$0; echo $cmd | base64 -d | /bin/bash"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

