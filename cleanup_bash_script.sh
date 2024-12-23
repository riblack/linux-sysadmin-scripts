#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Overview: The function of this script is to automatically perform some manual cleanup tasks so that 
#     we are on common ground (spacing, etc) between the editing styles of myself, declare -f, and chatgpt.

# Add a space between the bash function name and the ().
# Add a newline (\n) between () and { when there is a space in between.
# Remove trailing spaces and tabs from each line.
# Removes semicolons (;) from the end of a line if not preceded by another semicolon.

# FIXME need to skip if the semicolon belongs to an if statement (preceeding by a backslash)
# find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -exec touch -d "@${FILE_DATESTAMP_EARLIEST}" {} \;

cleanup_bash_script ()
{

    sed -e 's,\([a-zA-Z_][a-zA-Z0-9_]*\)\(()\),\1 \2,' \
        -e 's,\(()\) \({\),\1\n\2,' \
        -e 's,[[:space:]]*$,,' \
        -e 's,\([^;]\);$,\1,'
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

