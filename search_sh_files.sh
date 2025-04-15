#!/bin/bash
# search_sh_files.sh - Search .sh files (in current directory only) by modification time
# Usage:
#   ./search_sh_files.sh [-i] <pattern>
#   -i          : case-insensitive grep
#   <pattern>   : the text pattern to search for

set -euo pipefail

# --- Parse options ---
case_insensitive=""
while getopts ":i" opt; do
    case $opt in
    i) case_insensitive="-i" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND -1))

# --- Validate input ---
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [-i] <pattern>"
  exit 1
fi

pattern="$1"

# --- Main logic ---
find . -maxdepth 1 -type f -name '*.sh' -printf "%T@ %p\n" |
  sort -n |
  cut -d' ' -f2- |
  tr '\n' '\0' |
  xargs -0 -r -I{} -- grep -H $case_insensitive -- "$pattern" "{}"

