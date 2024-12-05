#!/usr/bin/env bash

cds () 
{ 
    SCRIPTS_DIR="${HOME}/scripts"
    [ -d "${SCRIPTS_DIR}" ] || mkdir -p "${SCRIPTS_DIR}"
    cd "${SCRIPTS_DIR}"
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

