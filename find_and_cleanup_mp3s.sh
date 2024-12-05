#!/usr/bin/env bash

read -p "WARNING: This script is under contruction"

process_main_file ()
{
    local main_file="$1"
    unset file_md5  # Clear file_md5 to ensure fresh calculation per main file
    file_name=$(basename "$main_file")
    file_size=$(stat -c%s "$main_file")

    echo "Processing main file: $main_file (size: $file_size)"

    # Step 3: Locate system-wide matches for the file name
    while IFS= read -r found_file 0<&4; do
        # Skip the main file itself and any non-regular files (e.g., symlinks, directories)
        if [ "$found_file" == "$main_file" ] && continue || [ ! -f "$found_file" ] || [ -h "$found_file" ]; then
            file_type=$( [ -h "$found_file" ] && echo "symlink" || echo "non-regular file")
            skipped_files+=("$found_file ($file_type)")
            continue
        fi

        # Check the file size first
        found_file_size=$(stat -c%s "$found_file")
        if [ "$file_size" -ne "$found_file_size" ]; then
            skipped_files+=("$found_file (size mismatch)")
            continue
        fi

        # Calculate MD5 for the main file only once
        if [ -z "$file_md5" ]; then
            file_md5=$(md5sum "$main_file" | awk '{print $1}')
        fi

        # Calculate MD5 for the found file and compare
        found_file_md5=$(md5sum "$found_file" | awk '{print $1}')
        if [ "$file_md5" == "$found_file_md5" ]; then
            # Step 5: Interactive deletion for exact matches outside main directory
            if [[ "$found_file" != "$main_dir"* ]]; then
                echo "Duplicate found: $found_file (matching size and md5)"
                rm -vi "$found_file" && processed_files+=("$found_file (deleted)") || processed_files+=("$found_file (kept)")
            else
                processed_files+=("$found_file (in main directory, not deleted)")
            fi
        else
            skipped_files+=("$found_file (md5 mismatch)")
        fi
    done 4< <( locate "$file_name" )
}

find_and_cleanup_mp3s ()
{
    local main_dir="$1"
    local maxdepth="${2:-infinite}"  # Default to infinite depth if not provided
    local processed_files=()
    local skipped_files=()

    # Step 1: Update locate database
    echo "Updating locate database..."
    sudo updatedb

    # Step 2: Find regular mp3 files in main directory with optional max depth
    echo "Searching for mp3 files in $main_dir with max depth $maxdepth..."
    while IFS= read -r main_file 0<&3; do
        process_main_file "$main_file"
    done 3< <(
        if [[ "$maxdepth" == "infinite" ]]; then
            find "$main_dir" -type f -name "*.mp3"
        else
            find "$main_dir" -maxdepth "$maxdepth" -type f -name "*.mp3"
        fi
    )

    # Step 6: Final report
    echo -e "\n--- Final Report ---"
    echo "Processed files:"
    for file in "${processed_files[@]}"; do
        echo "  $file"
    done

    echo -e "\nSkipped files:"
    for file in "${skipped_files[@]}"; do
        echo "  $file"
    done
}

# Usage example:
# find_and_cleanup_mp3s "/mnt/MEDIA/originals" 1

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

