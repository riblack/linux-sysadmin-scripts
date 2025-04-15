#!/bin/bash

set -euo pipefail

dry_run=false
log_file="organize_files.log"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo -e "${YELLOW}Usage: $0 [--dry-run] <directory1> [directory2 ...]${NC}"
    exit 1
}

# Parse arguments
declared_dirs=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
        *)
            declared_dirs+=("$1")
            shift
            ;;
    esac
done

[[ ${#declared_dirs[@]} -lt 1 ]] && usage

echo "--- Run started at $(date) ---" >>"$log_file"

calculate_checksum() {
    sha256sum "$1" | awk '{print $1}'
}

log_and_echo() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
    echo "$message" >>"$log_file"
}

move_with_collision_check() {
    local src="$1"
    local dest="$2"
    local dup_dir="$3"

    if [[ ! -e "$dest" ]]; then
        $dry_run && log_and_echo "$BLUE" "Would move: $src -> $dest" || { mv "$src" "$dest" && log_and_echo "$GREEN" "Moved: $src -> $dest"; }
        return
    fi

    if [[ $(stat -c%s "$src") -eq $(stat -c%s "$dest") &&
    $(calculate_checksum "$src") == $(calculate_checksum "$dest") ]]; then
        # Identical, move to DUPLICATES
        base_name=$(basename "$src")
        dup_target="$dup_dir/$base_name"
        if [[ ! -e "$dup_target" ]]; then
            $dry_run && log_and_echo "$BLUE" "Would move duplicate: $src -> $dup_target" || { mv "$src" "$dup_target" && log_and_echo "$YELLOW" "Duplicate moved: $src -> $dup_target"; }
        else
            ext="${base_name##*.}"
            name="${base_name%.*}"
            count=1
            while [[ -e "$dup_dir/${name} (${count}).${ext}" ]]; do
                ((count++))
            done
            new_target="$dup_dir/${name} (${count}).${ext}"
            $dry_run && log_and_echo "$BLUE" "Would move duplicate with suffix: $src -> $new_target" || { mv "$src" "$new_target" && log_and_echo "$YELLOW" "Duplicate with suffix moved: $src -> $new_target"; }
        fi
    else
        # Different content, rename and move
        base_name=$(basename "$src")
        ext="${base_name##*.}"
        name="${base_name%.*}"
        count=1
        new_dest="$dest"
        while [[ -e "$new_dest" ]]; do
            new_dest="${dest%/*}/${name} (${count}).${ext}"
            ((count++))
        done
        $dry_run && log_and_echo "$BLUE" "Would move with rename: $src -> $new_dest" || { mv "$src" "$new_dest" && log_and_echo "$GREEN" "Renamed and moved: $src -> $new_dest"; }
    fi
}

for top_dir in "${declared_dirs[@]}"; do
    [[ -d "$top_dir" ]] || {
        log_and_echo "$RED" "Skipping non-directory: $top_dir"
        continue
    }

    top_dir="${top_dir%/}" # Remove trailing slash if any
    dup_dir="$top_dir/DUPLICATES"
    $dry_run || mkdir -p "$dup_dir"

    total_files=$(find "$top_dir" -maxdepth 1 -type f | wc -l)
    processed=0

    find "$top_dir" -maxdepth 1 -type f | while IFS= read -r file; do
        processed=$((processed + 1))
        echo -ne "\rProcessing file $processed of $total_files..." || true

        mod_date=$(date -r "$file" +%Y/%m/%d)
        target_dir="$top_dir/$mod_date"
        $dry_run || mkdir -p "$target_dir"

        base_name=$(basename "$file")
        target_path="$target_dir/$base_name"

        move_with_collision_check "$file" "$target_path" "$dup_dir"
    done
    echo -e "\rProcessed $processed files in $top_dir"
done

echo "--- Run ended at $(date) ---" >>"$log_file"
