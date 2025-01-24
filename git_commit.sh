#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# FIXME: todo, need to parrot back which files we will be updating through this process
# FIXME: possibly incorporate git diff, or at least ask if you want to see a diff

# Function to handle git commit
git_commit ()
{
    # Check if file(s) are specified
    [[ -n "$1" ]] || {
        git status
        printf "%s\n" "Specify the file(s) to stage and commit."
        return 1
    }

    # Prepare the list of files to stage
    file_list=$(while [[ -n "$1" ]]; do echo "$1"; shift; done)

    # Backup files
    mkdir -p /data/backups
    while IFS= read -r file 0<&3; do
        cp -avi "$file" "/data/backups/${file}_$(date "+%Y%m%d_%H%M%S").bak"
    done 3< <(echo "$file_list")

    # Show status
    git status

    # Prompt to proceed
    read -p "Pausing for you to review the above status. Press Enter to continue to git pull, or Ctrl+C to abort."

    # Pull the latest changes
    git pull
    read -p "Git pull complete. Press Enter to continue, or Ctrl+C to abort."

    # Show status
    git status

    # Prompt to proceed
    read -p "Pausing for you to review the above status. Press Enter to continue to git add the files, or Ctrl+C to abort."

    # Stage the files
    git add $file_list
    echo "Files staged: $file_list"
    git status
    read -p "Pausing for you to review staged files. Press Enter to continue, or Ctrl+C to abort."

    # Create a temporary file for the commit message template
    template=$(mktemp)
    cat ~/.gitmessage.txt > "$template"

    # Append git status and diff to the template
    {
        echo
        echo "# Status:"
        git status
        echo
        echo "# Changes:"
        git diff --staged
    } >> "$template"

    # Open the commit message template in vim
    vim "$template"

    # Extract the message (discarding comments)
    message=$(sed '/^#/d' "$template")

    # Check if the message is empty
    if [[ -z "$message" ]]; then
        echo "Empty commit message. Aborting."
        rm -f "$template"
        return 1
    fi

    # One last chance to abort the got commit
    read -p "Press enter when ready to proceed with the git commit (Ctrl+C to abort). "

    # Perform the commit
    echo "$message" | git commit -F -

    read -p "git commit complete. (enter to continue)" pause

    # Show status
    git status

    # Prompt to proceed
    read -p "Pausing for you to review the above status. Press Enter to continue, or Ctrl+C to abort."

    # Cleanup
    rm -f "$template"
    echo "Commit complete."

    # Push the changes
    read -p "Ready to push changes. Press Enter to continue, or Ctrl+C to abort."
    git push

    # Prompt to proceed
    read -p "Pausing for you to review the above git push results. Press Enter to continue, or Ctrl+C to abort."

    # Final status
    git status
    read -p "Git push complete. Press Enter to finish, or Ctrl+C to abort."

    git pull
    read -p "git pull complete. (enter to continue)" pause

    git status
    read -p "Pausing for a moment for you to read the above status before returning. (enter to continue)" pause
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

