#!/usr/bin/env bash

cdp () 
{ 
    LAST_PROJECT_NAME=$( cd "${HOME}/workspace"; ls -tr | tail -n 1 )
    LAST_PROJECT_DIR="${HOME}/workspace/${LAST_PROJECT_NAME}"
    [ -d "${LAST_PROJECT_DIR}" ] && cd "${LAST_PROJECT_DIR}"
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

