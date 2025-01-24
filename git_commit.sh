#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./backup_files.sh
. ./check_git_config.sh
. ./stage_files.sh
. ./create_commit_template.sh

git_commit ()
{

    # Initialize the files array with command-line arguments
    local files=("$@")

    # Add files already staged in "git add" section
    mapfile -t staged_files < <(git diff --cached --name-only)

    # Combine command-line files and staged files, avoiding duplicates
    for staged_file in "${staged_files[@]}"; do
        if [[ ! " ${files[*]} " =~ " $staged_file " ]]; then
            files+=("$staged_file")
        fi
    done

    # Debug output for collected files
    echo "Files to back up and commit:"
    printf "  %s\n" "${files[@]}"

    echo "Step 1: Backing up specified and staged files..."
    backup_files "${files[@]}"

    echo "Step 2: Checking Git configuration..."
    check_git_config

    echo "Step 3: Checking Git repository status..."
    git status
    echo

    echo "Step 4: Pulling latest changes from the remote repository..."
    git pull || { echo "Error: Failed to pull changes."; exit 1; }
    echo

    echo "Step 5: Staging files for commit..."
    stage_files "${files[@]}"
    echo

    echo "Step 6: Creating commit message template..."
    local template
    template=$(create_commit_template)
    echo "Opening commit message editor..."
    vim "$template"

    echo "Step 7: Validating and applying commit message..."
    local commit_message
    commit_message=$(sed '/^#/d' "$template")
    # Check if the commit_message is empty
    if [[ -z "$commit_message" ]]; then
        echo "Error: Empty commit message. Aborting commit."
        rm -f "$template"
        return 1
    fi

    echo "Commit message preview:"
    echo "-----------------------"
    echo "$commit_message"
    echo "-----------------------"
    read -p "Proceed with commit? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Aborting commit."
        rm -f "$template"
        exit 1
    fi

    # Perform the commit
    git commit -F "$template"

    # Cleanup
    rm -f "$template"
    echo "Commit completed successfully."
    echo

    echo "Step 8: Pushing changes to the remote repository..."
    git push || { echo "Error: Failed to push changes."; exit 1; }
    echo

    echo "Step 9: Pulling latest changes after push to sync repository..."
    git pull || { echo "Error: Failed to pull changes."; exit 1; }
    echo

    echo "Step 10: Final repository status:"
    git status
    echo "Workflow completed successfully."
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

