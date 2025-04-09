#!/bin/bash
# dhcp_history_diff.sh - Walk and compare DHCP config backups with filters

set -euo pipefail

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# === Check args ===
usage() {
    cat <<EOF
Usage: $0 [--interactive forward|backward] [--report] [--highlight <MAC|IP>] [--since <date>] [--until <date>]

Options:
  --interactive forward|backward   Step through diffs in chosen direction
  --report                         Print out diffs in ascending time
  --highlight <string>             Highlight a MAC/IP substring in diffs
  --since <date>                   Only include files modified after this date
  --until <date>                   Only include files modified before this date

If neither --interactive nor --report is given, the script defaults to --report.

Examples:
  $0 --interactive forward --highlight 48:21:0b:3d:dc:f9
  $0 --report --since "2025-04-01" --until "2025-04-07"
  $0 --highlight 192.168.42.7
EOF
    exit 1
}

# === Parse arguments ===
mode=""
direction=""
highlight_string=""
since_date=""
until_date=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --interactive)
            # Must have second arg: forward or backward
            [[ $# -lt 2 ]] && usage
            mode="interactive"
            direction="$2"
            shift 2
            ;;
        --report)
            mode="report"
            shift
            ;;
        --highlight)
            [[ $# -lt 2 ]] && usage
            highlight_string="$2"
            shift 2
            ;;
        --since)
            [[ $# -lt 2 ]] && usage
            since_date="$2"
            shift 2
            ;;
        --until)
            [[ $# -lt 2 ]] && usage
            until_date="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# === If no mode was specified, default to report ===
if [[ -z "$mode" ]]; then
    mode="report"
fi

# === Validate interactive direction if applicable ===
if [[ "$mode" == "interactive" ]]; then
    if [[ "$direction" != "forward" && "$direction" != "backward" ]]; then
        usage
    fi
fi

# === Function: Is it a valid DHCP config? ===
dhcp_is_valid() {
    local file="$1"
    [[ ! -s "$file" ]] && return 1
    grep -qE '^[ \t]*(host|subnet|range|hardware|option)' "$file" && return 0
    return 1
}

# === Parse time filters ===
since_sec=0
until_sec=9999999999

if [[ -n "$since_date" ]]; then
    since_sec=$(date -d "$since_date" +%s)
fi

if [[ -n "$until_date" ]]; then
    until_sec=$(date -d "$until_date" +%s)
fi

# === Build time-sorted & filtered file list ===
mapfile -t files < <(
    find . -type f -printf "%T@ %p\n" \
        | awk -v since="$since_sec" -v until="$until_sec" '{ if ($1 >= since && $1 <= until) print }' \
        | sort -n \
        | awk '{print $2}' \
        | while read -r f; do
            dhcp_is_valid "$f" && echo "$f"
        done
)

if [[ ${#files[@]} -lt 2 ]]; then
    echo -e "${RED}❌ Not enough valid DHCP files in selected range to compare.${RESET}"
    exit 1
fi

# === show_diff: color + optional highlight ===
show_diff() {
    local a="$1"
    local b="$2"
    local diff_output
    diff_output=$(diff -u "$a" "$b" || true)

    # If highlight_string is set, filter the diff lines to keep color on them
    if [[ -n "$highlight_string" ]]; then
        # Preserve standard diff lines (+, -, @, space) and highlight matches
        diff_output=$(echo "$diff_output" | grep -Ei --color=always "$highlight_string|^[-+@ ]")
    fi

    echo "$diff_output" | sed \
        -e "s/^+/${GREEN}+/" \
        -e "s/^-/${RED}-/" \
        -e "s/^@/${YELLOW}@/" \
        -e "s/$/${RESET}/" | less -R
}

# === INTERACTIVE MODE ===
if [[ "$mode" == "interactive" ]]; then
    echo -e "${YELLOW}🚀 Interactive mode [$direction]. Commands: [Enter]=next, b=back, r=repeat, q=quit${RESET}"

    # Setup index and direction
    if [[ "$direction" == "forward" ]]; then
        i=0
        step=1
    else
        i=$((${#files[@]} - 1))
        step=-1
    fi

    # Use i+step bounds check
    while ((i + step >= 0 && i + step < ${#files[@]})); do
        localA="${files[$i]}"
        localB="${files[$((i + step))]}"

        echo -e "\n${BLUE}Comparing:${RESET} [$localA] ↔ [$localB]"

        read -rp "Command ([Enter]=next, b=back, r=repeat, q=quit): " ans
        case "$ans" in
            q) break ;;
            b)
                ((i -= step))
                ((i -= step))
                ;;              # effectively i -= 2*step
            r) ((i -= step)) ;; # re-run same pair
            "") ;;              # do nothing, proceed
            *) ;;               # unknown input? just continue
        esac

        # Validate non-empty
        if [[ ! -s "$localA" || ! -s "$localB" ]]; then
            echo -e "${YELLOW}⚠️ Skipping unreadable or empty files${RESET}"
        # If we have vimdiff, use it
        elif command -v vimdiff &>/dev/null; then
            vimdiff "$localA" "$localB"
        else
            show_diff "$localA" "$localB"
        fi

        # Move forward/back
        ((i += step))
    done

# === REPORT MODE ===
elif [[ "$mode" == "report" ]]; then
    echo -e "${YELLOW}📄 Generating change report across DHCP backups...${RESET}"
    for ((idx = 0; idx < ${#files[@]} - 1; idx++)); do
        a="${files[$idx]}"
        b="${files[$((idx + 1))]}"
        ts_a=$(stat -c '%y' "$a")
        ts_b=$(stat -c '%y' "$b")

        echo -e "\n${BLUE}== Diff: $a ($ts_a) → $b ($ts_b) ==${RESET}"

        if [[ ! -s "$a" || ! -s "$b" ]]; then
            echo -e "${YELLOW}⚠️ Skipping unreadable or empty files${RESET}"
            continue
        fi

        show_diff "$a" "$b"
    done
fi
