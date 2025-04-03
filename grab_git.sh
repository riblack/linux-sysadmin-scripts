#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

. "$SCRIPT_DIR/log_error.sh"

grab_git() {
    local git_url="$1"
    shift || true
    local dry_run="no"

    for arg in "$@"; do
        case "$arg" in
            --dry-run) dry_run="yes" ;;
            *) ;;
        esac
    done

    if [[ -z "$git_url" ]]; then
        log_error "No git clone URL specified."
        return 1
    fi

    # Validate and parse GitHub URL
    if [[ "$git_url" =~ github\.com[:/]+([^/]+)/([^/.]+)(\.git)?$ ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
    else
        log_error "Unsupported or malformed GitHub URL: $git_url"
        return 1
    fi

    # --- Ensure log file is ready ---
    local log_file="/var/log/grab_git.log"
    "${SCRIPT_DIR}/init_logfile.sh" "$log_file" root adm 0640 --quiet \
        || "${SCRIPT_DIR}/init_logfile.sh" "$log_file" root adm 0640

    # --- Prepare clone paths ---
    local ts
    ts="$(date "+%Y%m%d_%H%M%S")"
    local dest1="$HOME/GITREPO/${github_user}/${repo_name}"
    local dest2="$HOME/git/${github_user}/${repo_name}"
    local dest3="$(pwd)/${repo_name}"

    # --- Log the intent ---
    {
        echo "$ts $git_url"
        echo "$ts Will clone to:"
        echo "  - $dest1"
        echo "  - $dest2"
        echo "  - [optional] $dest3"
    } | tee -a "$HOME/git/grab_git.log" "$HOME/GITREPO/grab_git.log" "$log_file"

    if [[ "$dry_run" == "yes" ]]; then
        log_info "Dry run: skipping clone"
        return 0
    fi

    # --- Create directory structure and clone ---
    (
        mkdir -p "$HOME/GITREPO/$github_user" "$HOME/git/$github_user"

        cd "$HOME/GITREPO/$github_user" && git clone "$git_url"
        cd "$HOME/git/$github_user" && git clone "$git_url"
    )

    # --- Optional clone into current dir ---
    current_dir=$(pwd)
    case "$current_dir" in
        "$HOME/GITREPO"*) ;;
        "$HOME/git"*) ;;
        "$HOME/scripts") ;;
        "$HOME") ;;
        *)
            read -p "Do you wish to download a copy in this directory ($current_dir)? " response
            local char="${response:0:1}"
            char="${char,,}"
            if [[ "$char" == "y" ]]; then
                git clone "$git_url"
                echo "$ts Cloned to: $dest3" >>"$log_file"
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
