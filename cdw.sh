#!/bin/bash

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace";
    [ -d "${WORKSPACE_DIR}" ] || echo mkdir -p "${WORKSPACE_DIR}";
    cd "${WORKSPACE_DIR}"
}
