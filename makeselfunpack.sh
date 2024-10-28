#!/usr/bin/env bash

unset -f makeselfunpack
makeselfunpack () 
{ 

    # Check if at least one file is provided
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <file1> [file2 ...]"
        exit 1
    fi

    cat <<'EOF'
selfunpack () 
{ 
    read -p "Are you in the right directory? (ctrl + c to abort) "
    cat <<'EOFTARBASE64' | base64 -d | tar -xzvf -
EOF

    tar -czf - "$@" | base64
    cat <<'EOF'
EOFTARBASE64
}
selfunpack 
EOF

}

makeselfunpack "$@"

