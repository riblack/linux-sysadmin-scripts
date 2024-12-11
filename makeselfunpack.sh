#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

makeselfunpack ()
{

    # Ensure at least one file is provided
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <file1> [file2 ...]"
        echo "Error: No files specified for packaging."
        exit 1
    fi


    # Create the tarball and encode it in base64
    OUTPUT=$( tar -czf - "$@" | base64 )

    # Create self-unpacking script
    cat <<'EOFPART1'
selfunpack () 
{
EOFPART1

    echo "    echo \"The following files will be unpacked:\""

    # Add file list to the unpacker
    for file in "$@"; do
        echo "    echo \"$file\""
    done

    cat <<'EOFPART2'
    read -p "Are you in the right directory? (ctrl + c to abort) "
    cat <<'EOFTARBASE64' | base64 -d | tar -xzvf -
EOFPART2

    # Embed the base64-encoded tarball
    echo "${OUTPUT}"

    cat <<'EOFPART3'
EOFTARBASE64
}
selfunpack
EOFPART3

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

