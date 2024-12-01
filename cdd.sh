#!/usr/bin/env bash

cdd () 
{ 
    DOWNLOAD_DIR="${HOME}/Downloads"
    [ -d "${DOWNLOAD_DIR}" ] && cd "${DOWNLOAD_DIR}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

