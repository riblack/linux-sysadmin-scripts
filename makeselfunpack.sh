#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

makeselfunpack ()
{
    # Available compression methods (in priority order)
    COMPRESSORS=("gzip" "xz" "zstd")
    declare -A COMPRESSOR_INFO=(
        [gzip]="gzip (high compatibility, moderate compression)"
        [xz]="xz (moderate compatibility, high compression)"
        [zstd]="zstd (low compatibility, fast and good compression)"
    )

    # Default compression
    SELECTED_COMPRESSOR=""

    # Parse command-line arguments
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            --compressor)
                shift
                if [[ -z "$1" || ! " ${COMPRESSORS[@]} " =~ " $1 " ]]; then
                    echo "Invalid or missing compressor. Use one of: ${COMPRESSORS[*]}"
                    exit 1
                fi
                SELECTED_COMPRESSOR="$1"
                ;;
            -h|--help)
                echo "Usage: $0 [options] <file1> [file2 ...]"
                echo
                echo "Options:"
                echo "  --compressor <method>   Choose a specific compression method:"
                for c in "${COMPRESSORS[@]}"; do
                    echo "                          $c - ${COMPRESSOR_INFO[$c]}"
                done
                echo "  -h, --help              Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done

    # Ensure at least one file is provided
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <file1> [file2 ...]"
        echo "Error: No files specified for packaging."
        exit 1
    fi

    # Auto-select compressor if not explicitly set
    if [ -z "$SELECTED_COMPRESSOR" ]; then
        for c in "${COMPRESSORS[@]}"; do
            if command -v "$c" >/dev/null 2>&1; then
                SELECTED_COMPRESSOR="$c"
                break
            fi
        done
    fi

    # Validate that a compressor is available
    if [ -z "$SELECTED_COMPRESSOR" ]; then
        echo "Error: No supported compression methods available on this system."
        echo "Supported methods: ${COMPRESSORS[*]}"
        exit 1
    fi

    # Indicate selected compressor
    echo "Selected compression method: $SELECTED_COMPRESSOR - ${COMPRESSOR_INFO[$SELECTED_COMPRESSOR]}"

    # Create the tarball, compress it, and encode it in base64
    case "$SELECTED_COMPRESSOR" in
        gzip)
            if tar --help | grep -q -- '--options'; then
                OUTPUT=$(tar -cf - "$@" --options gzip:compression-level=9 | base64)
            else
                OUTPUT=$(tar -cf - "$@" | gzip -9 | base64)
            fi
            ;;
        xz)
            OUTPUT=$(tar -cf - "$@" | xz -9e | base64)
            ;;
        zstd)
            OUTPUT=$(tar -cf - "$@" | zstd --ultra -22 - | base64)
            ;;
    esac

    # Create self-unpacking script
    cat <<'EOFPART1'
selfunpack () 
{
EOFPART1

    echo "    echo \"Selected compression method: $SELECTED_COMPRESSOR - ${COMPRESSOR_INFO[$SELECTED_COMPRESSOR]}\""
    echo "    echo \"The following files will be unpacked:\""

    # Add file list to the unpacker
    for file in "$@"; do
        echo "    echo \"$file\""
    done

    cat <<'EOFPART2'
    read -p "Are you in the right directory? (ctrl + c to abort) "
EOFPART2

    # Detect the compression method and apply the appropriate decompression step
    case "$SELECTED_COMPRESSOR" in
        gzip)
            echo "cat <<'EOFTARBASE64' | base64 -d | gzip -d | tar -xvf -"
            ;;
        xz)
            echo "cat <<'EOFTARBASE64' | base64 -d | xz -d | tar -xvf -"
            ;;
        zstd)
            echo "cat <<'EOFTARBASE64' | base64 -d | zstd -d | tar -xvf -"
            ;;
        *)
            echo "Error: Unsupported compression method for unpacking: $SELECTED_COMPRESSOR"
            exit 1
            ;;
    esac

    # Embed the base64-encoded tarball
    echo "${OUTPUT}"

    cat <<'EOFPART3'
EOFTARBASE64
}
selfunpack
EOFPART3

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

