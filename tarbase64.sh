#!/usr/bin/env bash

unset -f tarbase64
tarbase64 ()
{
    tar -czvf - "$1" | base64
}
declare -f tarbase64
tarbase64 "$@"
