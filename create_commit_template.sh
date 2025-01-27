#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./load_color_codes.def
. ./ensure_git_directory.sh
. ./validate_commit_message.sh

# Function to create the commit message template
create_commit_template ()
{
    echo "Ensuring the script is running in a Git repository..."
    if ! ensure_git_directory; then
        echo -e "${red}Exiting script due to missing Git repository.${reset}"
        return 1
    fi

    echo -e "${green}This is a valid Git repository.${reset}"

    local -n template_ref=$1  # Use nameref to modify the variable passed as an argument

    # Create a temporary file for the commit message template
    template_ref=$(mktemp)

    cat <<EOF >"$template_ref"

# Write your commit message above this line.
#
# ######################################################################
#
# Linus Torvalds' Git Commit Message Style:
#
# 1. Subject Line (50 characters max):
#    - Use a concise summary of the changes made.
#    - Write in the imperative mood (e.g., "Fix," "Add," "Update").
#    - Avoid using a period (.) at the end of the subject line.
#
# 2. Separate Subject Line and Body with a Blank Line:
#    - The blank line improves readability.
#
# 3. Body (72 characters max per line):
#    - Use paragraphs or bullet points to explain:
#        * What was changed.
#        * Why the change was made.
#        * Avoid details of *how* unless it's non-obvious.
#    - Wrap lines to 72 characters for better readability in logs.
#
# 4. Use Blank Lines Around Lists:
#    - Separate bullet lists or paragraphs with blank lines for clarity.
#
# 5. Signed-off-by Line:
#    - Add the line 'Signed-off-by: Your Name <your.email@example.com>' at
#      the bottom. This certifies that you authored the change or have
#      the right to submit it under the project’s license.
#
# Example Commit Message:
#
# feat: improve validation workflow
# feat: Improve validation workflow
# fix: Resolve crash on startup
# docs: Update README with usage instructions
#
# Refactor the validation process to include additional checks for empty
# subject lines and overly long body lines. This ensures compliance with
# the 50/72 rule and improves commit message quality.
#
# - Added subject line length validation.
# - Trimmed trailing spaces and blank lines.
# - Improved user feedback for violations.
#
# Signed-off-by: Jane Doe <jane.doe@example.com>
#
# Below is the status and diff of changes to help you craft the message:
EOF

    # Append git status and diff
    {
        echo
        echo ######################################################################
        echo
        echo "Status:"
        git status

        echo
        echo ######################################################################
        echo
        echo "Changes:"
        git diff --staged
    } | sed 's/^/# /' >>"$template_ref"

    # Open the template in vim interactively
    if [ -t 1 ]; then
        vim "$template_ref"
    else
        vim "$template_ref" < /dev/tty
    fi

    # Validate the commit message
    validate_commit_message "$template_ref"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

