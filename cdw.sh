#!/usr/bin/env bash

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace"
    [ -d "${WORKSPACE_DIR}" ] || mkdir -p "${WORKSPACE_DIR}"
    cd "${WORKSPACE_DIR}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

