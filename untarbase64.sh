#!/usr/bin/env bash

untarbase64 () 
{ 
    echo "Please paste the content to base64 decode and untar (are you in the correct directory): "
    echo "A blank line terminates the input. Only include the base64, don't include filenames."
    package=$(sed '/^$/q')
    echo "${package}" | base64 -d | tar -xzvf -
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

