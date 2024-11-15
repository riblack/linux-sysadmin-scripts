#!/usr/bin/env bash

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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

