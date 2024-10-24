# Bash Debugging

#!/bin/bash -xv

set -xv		turn on extra verbose debug
set +xv		turn off extra verbose debug

echo statements

Weird results from a new script you're testing?
Make sure you're not using an existing environment variable (start a new shell session and check if that variable already exists).
I was working on a new script and decided to use an array variable called GROUPS and was getting very unexpected results, it turns out that GROUPS is already an array variable, duh. (I was specifying group names, but when looking at the variable I found group numbers, what????). I used a different name (SPECIFIED_GROUPS) and the weirdness went away.

