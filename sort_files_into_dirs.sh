#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sort_files_into_dirs ()
{ 
    find . -maxdepth 1 -type f -printf "%TY/%Tm/%Td %p\\0" | xargs -0 -r -I{} bash -c 'mk_specified_dir_and_move_file ()
{
    while read dir file 0<&3; do
        mkdir -p "$dir";
        mv -vi "$file" "$dir/";
    done 3< <( echo "{}" )
}
mk_specified_dir_and_move_file'
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

