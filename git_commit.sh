#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/backup_files.sh"
. "$SCRIPT_DIR/check_git_config.sh"
. "$SCRIPT_DIR/stage_files.sh"
. "$SCRIPT_DIR/create_commit_template.sh"
. "$SCRIPT_DIR/ensure_git_directory.sh"

git_commit ()
{
    echo "Ensuring the script is running in a Git repository..."
    if ! ensure_git_directory; then
        echo -e "${red}Exiting script due to missing Git repository.${reset}"
        return 1
    fi

    echo -e "${green}This is a valid Git repository.${reset}"

    # Initialize the files array with command-line arguments
    local files=("$@")

    # Add files already staged in "git add" section
    mapfile -t staged_files < <(git diff --cached --name-only)

    # Combine command-line files and staged files, avoiding duplicates
    for staged_file in "${staged_files[@]}"; do
        if ! printf '%s\n' "${files[@]}" | grep -q -F -- "$staged_file"; then
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
    create_commit_template template  # Pass template as a reference

    echo "Step 7: Validating and applying commit message..."
    # Remove comments, trailing spaces, and blank lines at the bottom
    local commit_message
    commit_message=$(sed -e '/^#/d' \
                         -e 's/[[:space:]]*$//' \
                         "$template" \
                         | awk 'NF {p=1} p' \
                         | tac \
                         | awk 'NF {p=1} p' \
                         | tac)

    # Split commit message into subject and body
    local subject_line body_lines
    subject_line=$(echo "$commit_message" | sed -n '1p')
    body_lines=$(echo "$commit_message" \
                         | sed -e '1d' \
                         | awk 'NF {p=1} p')

    # Automatically enforce no period at the end of the subject line
    if [[ "$subject_line" =~ \.$ ]]; then
        echo "Warning: Subject line ends with a period. Removing the period."
        subject_line=${subject_line%.}
    fi

    # Validate subject line length
    if [[ ${#subject_line} -gt 50 ]]; then
        echo "Warning: Subject line exceeds 50 characters (${#subject_line})."
    fi

    # Validate body line lengths
    if echo "$body_lines" | grep -q '.\{73\}'; then
        echo "Warning: One or more body lines exceed 72 characters."
    fi

    # Ensure the subject line and body are not empty
    if [[ -z "$subject_line" ]]; then
        echo "Error: Commit message must have a subject line."
        rm -f "$template"
        return 1
    fi
    if [[ -z "$body_lines" ]]; then
        echo "Error: Commit message must have a body after the subject line."
        rm -f "$template"
        return 1
    fi

    # Reconstruct the commit message
    commit_message="${subject_line}

${body_lines}"

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
    echo "$commit_message" | git commit -F -

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
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

