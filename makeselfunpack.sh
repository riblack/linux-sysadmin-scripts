#!/usr/bin/env bash

makeselfunpack () 
{ 

    # Check if at least one file is provided
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <file1> [file2 ...]"
        exit 1
    fi

    OUTPUT=$( tar -czf - "$@" | base64 )

    cat <<'EOF'
selfunpack () 
{ 
    read -p "Are you in the right directory? (ctrl + c to abort) "
    cat <<'EOFTARBASE64' | base64 -d | tar -xzvf -
EOF

    echo "${OUTPUT}"
    cat <<'EOF'
EOFTARBASE64
}
selfunpack 
EOF

}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

