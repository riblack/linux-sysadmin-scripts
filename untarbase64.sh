#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

untarbase64 () 
{ 
    echo "Please paste the content to base64 decode and untar (are you in the correct directory): "
    echo "A blank line terminates the input. Only include the base64, don't include filenames."
    package=$(sed '/^$/q')
    echo "${package}" | base64 -d | tar -xzvf -
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

