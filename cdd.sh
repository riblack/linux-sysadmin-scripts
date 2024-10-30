#!/usr/bin/env bash

cdd () 
{ 
    DOWNLOAD_DIR="${HOME}/Downloads"
    [ -d "${DOWNLOAD_DIR}" ] && cd "${DOWNLOAD_DIR}"
}

# Source the footer
source bash_footer.template.live

