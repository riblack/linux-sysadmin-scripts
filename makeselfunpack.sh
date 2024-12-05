#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

