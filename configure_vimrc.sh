#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

configure_vimrc () 
{ 
    VIMRC_FILE=~/.vimrc
    settings=$(cat <<'EOF' | sed -e 's,[ \t]*\#.*$,,' | grep .
set hlsearch
set number
EOF
)
    while read entry 0<&3; do
        echo
        echo "Checking ${entry}"
        sed -e 's,[ \t]*".*$,,' "${VIMRC_FILE}" | grep "${entry}" && echo "present" || { 
            echo "adding..."
            echo "${entry}" >> "${VIMRC_FILE}"
        }
    done 3< <( echo "${settings}" )
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

