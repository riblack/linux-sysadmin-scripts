#!/usr/bin/env bash

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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

