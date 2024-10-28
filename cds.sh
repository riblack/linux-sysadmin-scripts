#!/bin/bash

cds () 
{ 
    SCRIPTS_DIR="${HOME}/scripts";
    [ -d "${SCRIPTS_DIR}" ] || echo mkdir -p "${SCRIPTS_DIR}";
    cd "${SCRIPTS_DIR}"
}

