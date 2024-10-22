#!/usr/bin/env bash

unset -f mcd
mcd () 
{ 
    mkdir -p "$1";
    cd "$1"
}
mcd "$@"

