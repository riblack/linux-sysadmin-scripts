#!/usr/bin/env bash

cdd () 
{ 
    DOWNLOAD_DIR="${HOME}/Downloads"
    [ -d "${DOWNLOAD_DIR}" ] && cd "${DOWNLOAD_DIR}"
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

