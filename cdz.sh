#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

# ---------------------------------------------------------------------------
# cdz — Change Directory to Zim journal
#
#  Search order (first existing wins):
#    $ZIM_BASE_DIR/YYYY/MM/DD   (today)
#    $ZIM_BASE_DIR/YYYY/MM
#    $ZIM_BASE_DIR/YYYY
#    $ZIM_BASE_DIR              (Journal root)
#    $ZIM_BASE_FALLBACK         (Notes root)
#
#  Options
#    -c, --create     mkdir -p the first non-existent candidate and cd there
#    DATE (arg)       Jump to an explicit YYYY[/MM[/DD]] path under Journal
#
#  Env vars
#    ZIM_BASE_FALLBACK   Default: "$HOME/Notebooks/Notes"
#    ZIM_BASE_DIR        Default: "$ZIM_BASE_FALLBACK/Journal"
# ---------------------------------------------------------------------------

cdz() {
    local fallback="${ZIM_BASE_FALLBACK:-$HOME/Notebooks/Notes}"
    local base="${ZIM_BASE_DIR:-$fallback/Journal}"
    local do_create=0 explicit=

    # --- option parsing -------------------------------------------------------
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c | --create) do_create=1 ;;
            *) explicit="$1" ;;
        esac
        shift
    done

    # --- build the candidate list --------------------------------------------
    local today month year
    today="$(date +%Y/%m/%d)"
    month="${today%/*}" # YYYY/MM
    year="${month%/*}"  # YYYY

    # If an explicit date was given, normalise it (strip leading /)
    [[ -n $explicit ]] && explicit="${explicit#/}"

    # Search list in priority order
    local -a candidates=()
    [[ -n $explicit ]] && candidates+=("$explicit")
    candidates+=("$today" "$month" "$year" "") # "" = Journal root
    local first_nonexistent=                   # tracks first missing dir

    # --- iterate until we cd somewhere ---------------------------------------
    local path full
    for path in "${candidates[@]}"; do
        full="${base}${path:+/$path}"

        if [[ -d $full ]]; then
            cd -- "$full" && return
        else
            [[ -z $first_nonexistent ]] && first_nonexistent=$full
        fi
    done

    # Last chance: the Notes root
    if [[ -d $fallback ]]; then
        cd -- "$fallback" && return
    fi

    # --create: make the very first missing candidate then cd
    if ((do_create)) && [[ -n $first_nonexistent ]]; then
        mkdir -p -- "$first_nonexistent" || {
            printf 'cdz: cannot create %s\n' "$first_nonexistent" >&2
            return 1
        }
        cd -- "$first_nonexistent" && return
    fi

    printf 'cdz: no matching journal path found under %s or %s\n' "$base" "$fallback" >&2
    return 1
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
