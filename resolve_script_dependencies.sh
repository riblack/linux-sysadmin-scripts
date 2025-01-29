#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"
. "$SCRIPT_DIR/debug.sh"

resolve_script_dependencies ()
{
    local script_list=()
    local resolved_list=()
    local pending_list=()
    DEBUG_MODE=0  # Default off
    API_MODE=0    # Default to human-readable mode

    # Usage message
    usage ()
{
        echo "Usage: resolve_script_dependencies [-d] [-a] <script1> [script2 ...]"
        echo "Options:"
        echo "  -d, --debug       Enable debug mode."
        echo "  -a, --api-mode    Enable API mode (output raw paths only)."
        echo "  -h, --help        Show this help message."
        echo "Examples:"
        echo "  resolve_script_dependencies myscript.sh"
        echo "  resolve_script_dependencies -d script1.sh script2.sh"
        echo "  resolve_script_dependencies -a script.sh  # API mode (raw paths only)"
    }

    # Argument parsing
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; return 0 ;;
            -d|--debug) DEBUG_MODE=1; shift ;;
            -a|--api-mode) API_MODE=1; shift ;;
            *)
                script_list+=("$1")
                shift
                ;;
        esac
    done

    # Validate input
    if [[ ${#script_list[@]} -eq 0 ]]; then
        echo "ERROR: No script files specified." >&2
        usage
        return 1
    fi

    # Debug message
    debug echo "Resolving dependencies for scripts: ${script_list[*]}"

    # Convert initial scripts to absolute paths
    for script in "${script_list[@]}"; do
        if [[ -f "$script" ]]; then
            script="$(realpath "$script")"
            pending_list+=("$script")
        else
            echo "WARNING: Script '$script' not found, skipping." >&2
        fi
    done

    # Recursive dependency resolution loop
    while [[ ${#pending_list[@]} -gt 0 ]]; do
        local current_script="${pending_list[0]}"
        pending_list=("${pending_list[@]:1}")  # Remove first element

        # Skip if already processed
        [[ " ${resolved_list[*]} " =~ " $current_script " ]] && continue

        # Validate script existence **again** for discovered dependencies
        if [[ ! -f "$current_script" ]]; then
            echo "WARNING: Script '$current_script' not found, skipping." >&2
            continue
        fi

        # Mark as resolved
        resolved_list+=("$current_script")

        # Debug message
        debug echo "Analyzing script: $current_script"

        # Extract dependencies (dot-source or source)
        local deps
        deps=$(grep -E '^\s*(\.|source)\s+["]?[^#"]+' "$current_script" | awk '{print $2}' | tr -d '"')

        for dep in $deps; do
            # Handle $SCRIPT_DIR or other variables
            if [[ "$dep" == *'$'* ]]; then
                local dep_eval
                dep_eval=$(eval echo "$dep")  # Expand variables like $SCRIPT_DIR
                dep_path="$dep_eval"
            else
                # Convert relative paths to absolute paths
                if [[ "$dep" != /* ]]; then
                    dep_path="$(dirname "$current_script")/$dep"
                else
                    dep_path="$dep"
                fi
            fi

            # Resolve full path
            dep_path="$(realpath "$dep_path" 2>/dev/null || echo "$dep_path")"

            # Debug message
            debug echo "Found dependency: $dep_path"

            # Validate if dependency exists **before adding it**
            if [[ -f "$dep_path" && ! " ${resolved_list[*]} " =~ " $dep_path " ]]; then
                pending_list+=("$dep_path")
            else
                echo "WARNING: Script '$dep_path' not found, skipping." >&2
            fi
        done
    done

    # Output resolved dependencies
    if [[ "$API_MODE" -eq 1 ]]; then
        printf "%s\n" "${resolved_list[@]}"  # API mode: raw output
    else
        echo "Resolved dependencies:"
        printf "%s\n" "${resolved_list[@]}"
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${red}Footer template missing. Skipping...${reset}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi

