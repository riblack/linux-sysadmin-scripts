#!/bin/bash

cdw () 
{ 
    WORKSPACE_DIR="${HOME}/workspace";
    [ -d "${WORKSPACE_DIR}" ] || mkdir -p "${WORKSPACE_DIR}";
    cd "${WORKSPACE_DIR}"
}

