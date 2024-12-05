#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ipa_change_user_shell_global_default () 
{ 

    ipa config-mod --defaultshell=/bin/bash

    # verify the change
    # ipa config-show

    # verify by testing
    # ipa user-add testuser --first="Test" --last="User"
    # ipa user-show testuser

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

