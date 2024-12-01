#!/usr/bin/env bash

cds () 
{ 
    SCRIPTS_DIR="${HOME}/scripts"
    [ -d "${SCRIPTS_DIR}" ] || mkdir -p "${SCRIPTS_DIR}"
    cd "${SCRIPTS_DIR}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

