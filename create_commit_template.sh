#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create the commit message template
create_commit_template ()
{
    # Create a temporary file for the commit message template
    local template
    template=$(mktemp)

    cat <<EOF >"$template"

# Write your commit message above this line.
#
# Suggested format:
# <type>: <short summary>
#
# Examples:
# feat: Add a new feature
# fix: Correct a bug
# docs: Update documentation
#
# Guidelines:
# - Separate subject from body with a blank line
# - Limit the subject line to 50 characters
# - Use the imperative mood in the subject line
# - Wrap the body at 72 characters
# - Explain *what* and *why*, not *how*
#
# Below is the status and diff of changes to help you craft the message:
EOF
    # Append git status and diff to the template
    {
        echo
        echo "Status:"
        git status

        echo
        echo "Changes:"
        git diff --staged
    } | sed 's/^/# /' >>"$template"

    echo "$template"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

