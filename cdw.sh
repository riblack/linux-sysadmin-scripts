#!/usr/bin/env bash

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace"
    [ -d "${WORKSPACE_DIR}" ] || mkdir -p "${WORKSPACE_DIR}"
    cd "${WORKSPACE_DIR}"
}

# Source the footer
source bash_footer.template.live

