#!/usr/bin/env bash

# FIXME: todo, need to parrot back which files we will be updating through this process
# FIXME: possibly incorporate git diff, or at least ask if you want to see a diff

git_commit () 
{ 
    [[ -n "$1" ]] || { 
        git status;
        printf "%s\n" "Specify the file(s) to send."
        return 1
    };
    file_list=$( while [[ -n "$1" ]]; do echo $1; shift; done )
    git status
    read -p "Pausing for a moment for you to read the above status before pulling. (enter to continue)" pause
    git pull
    read -p "Git pull complete. (enter to continue)" pause
    git status
    read -p "Pausing for a moment for you to read the above status before asking you for your commit message. (enter to continue)" pause
    read -p "Enter your commit message: " commit_message
    read -p "Thank you for your commit message. Proceeding to add files next.  (enter to continue)" pause
    git add $file_list
    read -p "git add complete. (enter to continue)" pause
    git status
    read -p "Pausing for a moment for you to read the above status before comitting next. (enter to continue)" pause
    git commit -m "${commit_message}"
    read -p "git commit complete. (enter to continue)" pause
    git status
    read -p "Pausing for a moment for you to read the above status before pushing. (enter to continue)" pause
    git push
    read -p "git push complete. (enter to continue)" pause
    git status
    read -p "Pausing for a moment for you to read the above status before pulling. (enter to continue)" pause
    git pull
    read -p "git pull complete. (enter to continue)" pause
    git status
    read -p "Pausing for a moment for you to read the above status before returning. (enter to continue)" pause
}

# Source the footer
source bash_footer.template.live

