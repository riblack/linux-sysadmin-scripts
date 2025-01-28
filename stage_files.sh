#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/debug.sh"
. "$SCRIPT_DIR/ensure_git_directory.sh"

# Function to stage files
stage_files ()
{
    echo "Ensuring the script is running in a Git repository..."
    if ! ensure_git_directory; then
        echo -e "${red}Exiting script due to missing Git repository.${reset}"
        return 1
    fi

    echo -e "${green}This is a valid Git repository.${reset}"

    local verbose=false
    local files=()
    local skipped=0

    # Argument parsing with case/esac
    for arg in "$@"; do
        case "$arg" in
            -v|--verbose)
                verbose=true
                ;;
            -h|--help)
                echo -e "${green}Usage:${reset} stage_files.sh [-v|--verbose] [file1 file2 ...]"
                echo "Stages files for commit."
                echo -e "${green}Options:${reset}"
                echo -e "  ${green}-v, --verbose${reset}   Enable verbose output"
                echo -e "  ${green}-h, --help${reset}      Show this help message"
                return 0
                ;;
            -*)
                echo -e "${red}Error:${reset} Unknown option '$arg'. Use --help for usage information."
                return 1
                ;;
            *)
                files+=("$arg")
                ;;
        esac
    done

    # Debug logging
    debug "Verbose mode: $verbose"
    debug "Files to stage: ${files[*]}"

    # Check for verbose mode
    if $verbose; then
        echo -e "${green}Staging files in verbose mode...${reset}"
    fi

    # Check if no files are provided as arguments
    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${red}No files specified. Checking for already staged files...${reset}"

        # Check if there are files already staged
        if ! git diff --cached --quiet; then
            echo -e "${green}Files already staged for commit:${reset}"
            git diff --cached --name-only
            return 0  # Exit the function since files are already staged
        fi

        # If no files are specified and none are staged, exit with error
        echo -e "${red}Error:${reset} No files specified or staged. Nothing to commit."
        return 1
    fi

    # If files are provided, stage them
    echo -e "${green}Staging the following files:${reset}"
    for file in "${files[@]}"; do
        if [[ -f "$file" || -d "$file" ]]; then
            printf "  %s\n" "$file"
            git add -- "$file"
            $verbose && echo -e "${green}Staged:${reset} $file"
            debug "Added '$file' to staging."
        else
            echo -e "${red}Warning:${reset} '$file' does not exist or is not a regular file. Skipping..."
            debug "Skipping '$file' as it does not exist or is not a regular file."
            skipped=$((skipped + 1))
        fi
    done

    # Verbose summary
    if $verbose; then
        echo -e "${green}Summary:${reset} Staged $(( ${#files[@]} - skipped )) files, skipped $skipped files."
    fi

    # Return 2 if any files were skipped
    if (( skipped > 0 )); then
        echo -e "${red}Warning:${reset} $skipped file(s) were skipped."
        return 2
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

