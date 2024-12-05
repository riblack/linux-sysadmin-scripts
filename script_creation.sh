#!/usr/bin/env bash

# ===========================
# Example Bash Script
# Version: 0.1
# ===========================

# Global Variables
DEBUG_MODE=0
SCRIPT_VERSION="0.1"
SCRIPT_NAME="$(basename "$0")"

# Load External Functions

# Load an error handler for displaying error messages
if [ -f "error.sh" ]; then
    # shellcheck source=/dev/null
    . error.sh
else
    # Otherwise a default definition is used
    error() {
        echo "ERROR: $*" >&2
    }
fi

. debug.sh
. debug_run.sh

# Functions

# Print usage information
usage() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo "Options:"
    echo "  -h, --help        Show this help message and exit"
    echo "  -v, --version     Display the script version and exit"
    echo "  -d, --debug       Enable debug mode (shows debug messages)"
}

# Print the script version
version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

# DEBUG
# unset -f this_script_name to prevent wasting time on debugging the wrong issue
unset -f script_creation

# Example function encapsulating the main logic
script_creation ()
{

    # Enable bash debugging for everything... (from here forward)
    debug_run set -xv

    # Banner to differentiate runs
    debug "============== $(date '+%H:%M:%S') =============="

    # Debug statements saying where we are in the run of the script
    debug "This is at the beginning of the run."

    # Parse command-line arguments
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                version
                exit 0
                ;;
            -d|--debug)
                DEBUG_MODE=1
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done

    # Enable bash debugging for a specific block
    debug_run set -xv

    # Example variable usage
    myvar="Hello World"

    # Thoroughly examine the variable contents
    debug "Examining variable myvar:"
    debug_run xxd -g 1 <<< "$myvar"

    # Perform some operations with error handling
    echo "$myvar"
    result=$?
    if [ $result -gt 0 ]; then
        error "This is a test error message."
        return $result
    fi

    # Disable bash debugging for the above specific block
    debug_run set +xv

    # Debug message indicating end of function
    debug "Exiting script_creation function."

    # save return value of above command
    return_value=$?

    # Turn off bash debugging
    debug_run set +xv

    # return with the proper return value (as saved above)
    return $return_value
}
declare -f script_creation

# The following is my standard footer that I use for all my scripts
# below lives in my bash_footer stub file
# the actual payload lives in my bash_footer live file

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

