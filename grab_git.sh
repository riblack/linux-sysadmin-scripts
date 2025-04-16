#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/log_error.sh"
. "$SCRIPT_DIR/log_info.sh"

grab_git() {
    local git_url="$1"
    shift || true

    local dry_run="no"
    local include_forks="no"
    local include_archived="no"
    local max_repos=100
    local github_token="${GITHUB_TOKEN:-}"

    for arg in "$@"; do
        case "$arg" in
            --dry-run) dry_run="yes" ;;
            --include-forks) include_forks="yes" ;;
            --include-archived) include_archived="yes" ;;
            --max=*) max_repos="${arg#*=}" ;;
            *) ;;
        esac
    done

    if [[ -z "$git_url" ]]; then
        log_error "No git clone URL specified."
        return 1
    fi

    # Parse GitHub URL
    if [[ "$git_url" =~ github\.com[:/]+([^/]+)(/([^/]+))?(\.git)?$ ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[3]}"
    else
        log_error "Unsupported or malformed GitHub URL: $git_url"
        return 1
    fi

    # --- Handle full user clone mode ---
    if [[ -z "$repo_name" ]]; then
        log_info "Fetching repositories for GitHub user: $github_user"

        local api_url="https://api.github.com/users/${github_user}/repos?per_page=100"
        local repo_data

        if [[ -n "$github_token" ]]; then
            repo_data=$(curl -s -H "Authorization: token $github_token" "$api_url")
        else
            repo_data=$(curl -s "$api_url")
        fi

        if [[ -z "$repo_data" ]]; then
            log_error "Failed to fetch repository data for $github_user"
            return 1
        fi

        local count=0

        echo "$repo_data" | jq -r '.[] | "\(.name) \(.clone_url) \(.fork) \(.archived)"' \
            | while read -r name clone_url is_fork is_archived; do
                ((count++))
                [[ "$count" -gt "$max_repos" ]] && break

                if [[ "$is_fork" == "true" && "$include_forks" != "yes" ]]; then
                    log_info "Skipping forked repo: $name"
                    continue
                fi

                if [[ "$is_archived" == "true" && "$include_archived" != "yes" ]]; then
                    log_info "Skipping archived repo: $name"
                    continue
                fi

                log_info "[$count] Processing: $clone_url"
                grab_git "$clone_url" "$@"
                sleep 60 # Throttle
            done

        return 0
    fi

    # --- Define log file ---
    LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/grab_git"
    mkdir -p "$LOG_DIR"
    log_file="$LOG_DIR/grab_git.log"

    # --- Ensure log file is usable ---
    "$SCRIPT_DIR/init_logfile.sh" "$log_file" "$USER" "$USER" 0644 --quiet \
        || "$SCRIPT_DIR/init_logfile.sh" "$log_file" "$USER" "$USER" 0644

    local ts
    ts="$(date "+%Y%m%d_%H%M%S")"

    # --- Prepare paths ---
    local base1="$HOME/GITREPO/${github_user}/${repo_name}"
    local base2="$HOME/git/${github_user}/${repo_name}"
    local base3
    base3="$(pwd)/${github_user}/${repo_name}"

    # Adjust paths if they already exist
    local dest1="$base1"
    local dest2="$base2"
    local dest3="$base3"

    [[ -d "$dest1" ]] && dest1="${base1}_${ts}"
    [[ -d "$dest2" ]] && dest2="${base2}_${ts}"
    [[ -d "$dest3" ]] && dest3="${base3}_${ts}"

    # --- Log the intent ---
    {
        echo "$ts $git_url"
        echo "$ts Will clone to:"
        echo "  - $dest1"
        echo "  - $dest2"
        echo "  - [optional] $dest3"
    } | tee -a "$HOME/git/grab_git.log" "$HOME/GITREPO/grab_git.log" "$log_file"

    if [[ "$dry_run" == "yes" ]]; then
        log_info "Dry run: skipping actual clone."
        return 0
    fi

    # --- Create directory structure and clone ---
    (
        mkdir -p "$(dirname "$dest1")" "$(dirname "$dest2")"
        cd "$(dirname "$dest1")" && git clone "$git_url" "$(basename "$dest1")"
        sleep 60
        cd "$(dirname "$dest2")" && git clone "$git_url" "$(basename "$dest2")"
        sleep 60
    )

    # --- Optional clone into current dir ---
    current_dir=$(pwd)
    case "$current_dir" in
        "$HOME/GITREPO"*) ;;
        "$HOME/git"*) ;;
        "$HOME/scripts") ;;
        "$HOME") ;;
        *)
            read -r -p "Do you wish to download a copy in this directory ($current_dir)? " response
            local char="${response:0:1}"
            char="${char,,}"
            if [[ "$char" == "y" ]]; then
                mkdir -p "$(dirname "$dest3")"
                git clone "$git_url" "$dest3"
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
