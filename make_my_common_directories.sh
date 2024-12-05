#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

make_my_common_directories ()
{

    DIRLIST=$( cat <<EOF | sed -e 's,[ \t]*\#.*$,,' | grep .
/data/backups
$HOME/bin
$HOME/scripts
EOF
    )

    while read dir 0<&3; do
        [ -d "${dir}" ] || mkdir -p "${dir}"
    done 3< <( echo "$DIRLIST" )

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

