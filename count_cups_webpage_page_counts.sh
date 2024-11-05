#!/usr/bin/env bash

count_cups_webpage_page_counts () 
{ 
    file="$1";
    printer="$2";
    cat "$file" | grep --color=auto "$printer" | cut -d'	' -f5 | awk '{sum += $NF} END {print "Total Pages Printed: ", sum}'
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

