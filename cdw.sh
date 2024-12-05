#!/usr/bin/env bash

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace"
    [ -d "${WORKSPACE_DIR}" ] || mkdir -p "${WORKSPACE_DIR}"
    cd "${WORKSPACE_DIR}"
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

