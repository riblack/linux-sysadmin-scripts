#!/usr/bin/env bash

create_mp3_softlinks() {
    local source="$1"
    local dest="$2"
    local use_absolute="${3:-}"

    # Check if both source and destination directories are specified
    if [ -z "$source" ] || [ -z "$dest" ]; then
        echo "Usage: create_softlinks <source_directory> <destination_directory> [--absolute]"
        echo "The source directory should contain the files you want to link to."
        echo "The destination directory is where the soft links will be created."
        echo "Use '--absolute' as the third argument to create absolute links instead of relative ones."
        return 1
    fi

    # Verify the source directory exists
    if [ ! -d "$source" ]; then
        echo "Source directory '$source' does not exist. Exiting."
        return 1
    fi

    # Verify the destination directory exists
    if [ ! -d "$dest" ]; then
        echo "Destination directory '$dest' does not exist. Exiting."
        return 1
    fi

    # Prevent linking within the same directory
    if [ "$(cd "$source" && pwd)" = "$(cd "$dest" && pwd)" ]; then
        echo "Source and destination directories are identical. Exiting."
        return 1
    fi

    # Link creation mode
    echo "Creating symbolic links in '$dest' for *.mp3 files from '$source'..."
    cd "$dest" || { echo "Failed to navigate to destination directory. Exiting."; return 1; }

    # Iterate over each mp3 file in the source directory
    find "$source" -type f -name '*.mp3' | while read -r file; do
        if [ "$use_absolute" = "--absolute" ]; then
            # Use absolute path for the link
            ln -s "$file" .
        else
            # Calculate and use relative path from destination to source file
            rel_path=$(realpath --relative-to="$dest" "$file")
            echo "Processing: $rel_path"
            ln -s "$rel_path" .
        fi
    done

    echo "Symbolic links created successfully."
}

# Source footer if it exists
[ -f "bash_footer.template.live" ] && source bash_footer.template.live || echo "Footer template missing. Skipping..."

