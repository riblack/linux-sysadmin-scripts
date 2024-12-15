# Add a space between the bash function name and the ().
# Add a newline (\n) between () and { when there is a space in between.
# Remove trailing spaces and tabs from each line.
# Removes semicolons (;) from the end of a line if not preceded by another semicolon.

# FIXME need to skip if the semicolon belongs to an if statement (preceeding by a backslash)
# find . -maxdepth 1 -type f -name "*$(echo "${VIDEO_HANDLE}" | sed -e 's,\[,\\&,g' -e 's,\],\\&,g')*" -exec touch -d "@${FILE_DATESTAMP_EARLIEST}" {} \;

sed -e 's,\([a-zA-Z_][a-zA-Z0-9_]*\)\(()\),\1 \2,' \
    -e 's,\(()\) \({\),\1\n\2,' \
    -e 's,[[:space:]]*$,,' \
    -e 's,\([^;]\);$,\1,'
