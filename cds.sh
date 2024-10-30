#!/usr/bin/env bash

cds () 
{ 
    SCRIPTS_DIR="${HOME}/scripts"
    [ -d "${SCRIPTS_DIR}" ] || mkdir -p "${SCRIPTS_DIR}"
    cd "${SCRIPTS_DIR}"
}

# Source the footer
source bash_footer.template.live

