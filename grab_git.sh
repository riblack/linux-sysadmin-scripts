#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

. "$SCRIPT_DIR/error.sh"

grab_git() {
    if [[ -z "$1" ]]; then
        error "No git clone url specified."
        return 1
    fi

    git_url="$1"

    # Extract GitHub username and repo name
    if [[ "$git_url" =~ github\.com[:/]+([^/]+)/([^/.]+)(\.git)?$ ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
    else
        error "Unsupported or malformed GitHub URL: $git_url"
        return 1
    fi

    mkdir -p ~/GITREPO/"$github_user"
    mkdir -p ~/git/"$github_user"

    log_entry="$(date "+%Y%m%d_%H%M%S") $git_url"
    printf '%s\n' "$log_entry" >>~/GITREPO/grab_git.log
    printf '%s\n' "$log_entry" >>~/git/grab_git.log

    (
        cd ~/GITREPO/"$github_user" && git clone "$git_url"
        cd ~/git/"$github_user" && git clone "$git_url"
    )

    current_dir=$(pwd)

    case "${current_dir}" in
        ~/GITREPO*) ;;
        ~/git*) ;;
        ~/scripts) ;;
        ~) ;;
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
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
