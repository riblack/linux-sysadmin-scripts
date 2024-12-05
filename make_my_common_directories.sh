#!/usr/bin/env bash

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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

