#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. error.sh

grab_git () 
{ 

    if [[ -z "$1" ]]; then
        error "No git clone url specified."
        return 1
    fi

    git_url="$1"

    mkdir -p ~/GITREPO
    mkdir -p ~/git

    printf '%s %s\n' "$(date "+%Y%m%d_%H%M%S")" "$git_url" >> ~/GITREPO/grab_git.log
    printf '%s %s\n' "$(date "+%Y%m%d_%H%M%S")" "$git_url" >> ~/git/grab_git.log

    ( cd ~/GITREPO
    git clone "$git_url"
    cd ~/git
    git clone "$git_url" )

    current_dir=$(pwd)

    case "${current_dir}" in 
        ~/GITREPO)

        ;;
        ~/git)

        ;;
        ~/scripts)

        ;;
        ~)

        ;;
        *)
            read -p "Do you wish to download a copy in this directory ($(pwd))? " response
            char=${response:0:1}
            char=${char,,}

            if [[ "$char" == "y" ]]; then
                git clone "$git_url"
            fi
        ;;
    esac
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

