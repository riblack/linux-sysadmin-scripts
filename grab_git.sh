#!/usr/bin/env bash

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
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

