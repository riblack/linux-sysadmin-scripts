#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripting_dependency_checker ()
{

    case $- in
        *f*)
            echo "found f so no globbing (set -f)" >&2
            cleanup='set -f'
        ;;
        *)
            echo "no f found so globbing is not enabled (set +f)" >&2
            cleanup='set +f'
        ;;
    esac

    set -f

    # Script to determine dependencies needed for any given script

    # Check if a script file was passed as an argument
    if [ -z "$1" ]; then
      echo "Usage: $0 <script-file>"
      exit 1
    fi

    SCRIPT="$1"

    # Check if the file exists
    if [ ! -f "$SCRIPT" ]; then
      echo "Error: File '$SCRIPT' not found!"
      exit 1
    fi

    # Initial character set (alphanumeric)
    base_chars='a-zA-Z0-9'
    # Extended character set for more aggressive inclusion
    additional_chars='_.+=:/!@#$%^&*-'

    # Store potential dependencies
    dependencies=""

    # Function to extract potential commands with a given character set
    extract_dependencies() {
      local chars="$1"
      dependencies+="$(cat "$SCRIPT" |
        # Remove all comments
        sed -E 's/^[ \t]*#.*//; s/[ \t][ \t]*#.*//' |
        # Replace non-command characters with newlines
        tr -cs "$chars" '\n' |
        # Filter for unique entries
        sort -u
      )\n"
    }

    # Start with base characters only
    echo "Processing character set: $base_chars"  # For debugging
    extract_dependencies "$base_chars"

    # Function to generate the full power set of a character set
    generate_power_set() {
      local chars="$1"
      local power_set=("")

      for (( i=0; i<${#chars}; i++ )); do
        local char="${chars:i:1}"
        local new_subsets=()

        # Add the current character to each subset in the power set
        for subset in "${power_set[@]}"; do
          new_subsets+=("$subset$char")
        done

        # Append the new subsets to the power set
        power_set+=("${new_subsets[@]}")
      done

      echo "${power_set[@]}"
    }

    # Get the power set of additional_chars
    combinations=$(generate_power_set "$additional_chars")

    # Process each subset from the power set by combining with base_chars
    for combo in $combinations; do
      # Combine the base characters with the current character combination
      char_set="${base_chars}${combo}"
      echo "Processing character set: $char_set"  # For debugging
      extract_dependencies "$char_set"
    done

    # Sort and deduplicate all found dependencies
    dependencies=$(echo -e "$dependencies" | sort -u | grep .)
    dependencies=$(echo -e "$dependencies" | grep -v '^*$' | grep . | grep -v -- "$(compgen -bk | grep . | sed -e 's,\[,\\[,g' -e 's,^\.$,\\.,' -e 's,.*,^&$,')")

    # Check if each potential command is available
    echo "Checking dependencies for '$SCRIPT':"
    for cmd in $dependencies; do
      if command -v -- "$cmd" &> /dev/null; then
        echo "===================================================================== Dependency found: $cmd"
        command -v -- "$cmd"
        dpkg -S -- $(command -v -- "$cmd") || dpkg -S -- $(realpath $(which "$cmd")) || dpkg -S -- "$cmd"
    echo "========================================================================================= lines where matches can be found:"
    cat "$SCRIPT" |
        # Remove all comments
        sed -E 's/^[ \t]*#.*//; s/[ \t][ \t]*#.*//' |
    grep -- "$cmd"
    echo "========================================================================================= end of lines matching."
      else
        echo "Missing dependency: $cmd" >/dev/null
      fi
    done

    $cleanup

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

