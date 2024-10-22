#!/usr/bin/env bash

unset -f git_commit
git_commit () 
{ 
    [[ -n "$1" ]] || { 
        git status;
        printf "%s\n" "Specify the file(s) to send.";
        return 1
    };
    file_list=$( while [[ -n "$1" ]]; do echo $1; shift; done );
    git status;
    read -p "Pausing for a moment for you to read the above status before pulling." pause;
    git pull;
    git status;
    read -p "Pausing for a moment for you to read the above status before adding files next." pause;
    git add $file_list;
    git status;
    read -p "Enter your commit message: " commit_message;
    read -p "Pausing for a moment for you to read the above status before comitting next." pause;
    git commit -m "${commit_message}";
    read -p "Finished with git commit." pause;
    git status;
    read -p "Pausing for a moment for you to read the above status before pushing." pause;
    git push;
    read -p "Finished with git push." pause;
    git status;
    read -p "Pausing for a moment for you to read the above status before pulling." pause;
    git pull;
    git status;
    read -p "Pausing for a moment for you to read the above status before returning." pause
}
# declare -f git_commit
git_commit "$@"

