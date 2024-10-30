#!/bin/bash

cdd () 
{ 
    DOWNLOAD_DIR="${HOME}/Downloads"
    [ -d "${DOWNLOAD_DIR}" ] && cd "${DOWNLOAD_DIR}";
}

