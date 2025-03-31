#!/bin/bash

# Determine script dir for sourcing lib
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=fullpath_lib.sh
source "${script_dir}/fullpath_lib.sh"

# Defaults
mode="default"
user="$(whoami)"
include_md5="yes"
show_header="yes"
use_fqdn="yes"
use_color="yes"
output_format="text"

# Parse arguments
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --scp)
            mode="scp"
            shift
            ;;
        --vim-url)
            mode="vim-url"
            shift
            ;;
        --user)
            user="$2"
            shift 2
            ;;
        --no-md5)
            include_md5="no"
            shift
            ;;
        --short)
            mode="short"
            shift
            ;;
        --no-header)
            show_header="no"
            shift
            ;;
        --no-color)
            use_color="no"
            shift
            ;;
        --json)
            output_format="json"
            shift
            ;;
        --yaml)
            output_format="yaml"
            shift
            ;;
        --fqdn)
            use_fqdn="yes"
            shift
            ;;
        --hostname)
            use_fqdn="no"
            shift
            ;;
        --help | -h)
            print_usage
            exit 0
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

# Get host info
fqdn=$(get_fqdn "$use_fqdn")
ip=$(get_primary_ip)

[[ "$show_header" == "yes" && "$mode" == "default" ]] && {
    echo "fqdn=${fqdn}"
    echo "ip=${ip}"
    echo
}

# Output collection for JSON/YAML
entries=()
file_count=0
total_size=0

for file in "${args[@]}"; do
    if [[ -e "$file" ]]; then
        ((file_count++))
        file_info=$(get_file_info "$file" "$include_md5")
        abs_path="$(cut -d'|' -f1 <<<"$file_info")"
        size_bytes=$(du -b --apparent-size --max-depth=0 "$file" | cut -f1)
        total_size=$((total_size + size_bytes))

        case "$output_format" in
            json | yaml) entries+=("$file_info") ;;
            *)
                case "$mode" in
                    default) output_default_mode "$fqdn" "$ip" "$file_info" "$use_color" ;;
                    short) output_short_mode "$fqdn" "$file_info" ;;
                    scp) output_scp_mode "$user" "$fqdn" "$file" ;;
                    vim-url) output_vim_url_mode "$user" "$fqdn" "$file" ;;
                esac
                echo
                ;;
        esac
    else
        echo "Error: '$file' does not exist." >&2
    fi
done

# Output JSON or YAML if requested
if [[ "$output_format" == "json" ]]; then
    print_json_output "${entries[@]}"
elif [[ "$output_format" == "yaml" ]]; then
    print_yaml_output "${entries[@]}"
fi

# Summary if default mode
if [[ "$mode" == "default" && $file_count -gt 1 ]]; then
    total_size_hr=$(numfmt --to=iec --suffix=B "$total_size")
    echo "Summary:"
    echo "- $file_count file(s)"
    echo "- Total size: $total_size_hr"
fi
