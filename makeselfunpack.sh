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

    # Generate the file manifest
    MANIFEST=$(printf "%s\n" "$@")

    # Create the tarball and encode it in base64
    OUTPUT=$( tar -czf - "$@" | base64 )

    cat <<'EOFPART1'
selfunpack () 
{ 
    echo "The following files will be unpacked:"
EOFPART1

    # Add the file manifest to the script
    echo "$MANIFEST" | sed 's/^/    echo "/;s/$/"/'

    cat <<'EOFPART2'
    read -p "Are you in the right directory? (ctrl + c to abort) "
    cat <<'EOFTARBASE64' | base64 -d | tar -xzvf -
EOFPART2

    # Include the encoded tarball
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

