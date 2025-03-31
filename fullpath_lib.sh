#!/bin/bash

print_usage() {
    cat <<EOF
Usage: fullpath.sh [OPTIONS] [file...]

Options:
  --scp           Output in scp-style format
  --vim-url       Output in vim scp:// format
  --user <name>   Override default username
  --no-md5        Skip computing MD5 checksum
  --short         Only output short_host:/path style
  --no-header     Suppress fqdn/ip header
  --no-color      Disable color output
  --fqdn          Use fully-qualified domain name (default)
  --hostname      Use short hostname instead of FQDN
  --json          Output structured JSON
  --yaml          Output structured YAML
  --help, -h      Show this help message
EOF
}

get_fqdn() {
    [[ "$1" == "yes" ]] && hostname -f || hostname -s
}

setup_colors() {
    if [[ "$1" == "yes" ]]; then
        color_path="\033[1;37m" # bold white
        color_info="\033[0;36m" # cyan
        color_md5="\033[0;33m"  # yellow
        color_reset="\033[0m"
    else
        color_path=""
        color_info=""
        color_md5=""
        color_reset=""
    fi
}

get_primary_ip() {
    ip -4 a | awk '/inet/ && !/127.0.0.1/ { print $2 }' | cut -d/ -f1 | head -n1
}

get_file_info() {
    local file="$1"
    local include_md5="$2"
    local abs_path perms owner size mtime md5sum
    abs_path=$(readlink -f "$file")
    perms=$(stat -c "%A" "$file")
    owner=$(stat -c "%U:%G" "$file")
    size=$(du -h --apparent-size --max-depth=0 "$file" | cut -f1)
    mtime=$(stat -c "%y" "$file" | cut -d. -f1)
    if [[ "$include_md5" == "yes" ]]; then
        md5sum=$(md5sum "$file" | cut -d' ' -f1)
    else
        md5sum="(skipped)"
    fi
    echo "$abs_path|$perms|$owner|$size|$mtime|$md5sum"
}

output_default_mode() {
    local fqdn=$1 ip=$2 file_info=$3
    IFS='|' read -r abs_path perms owner size mtime md5sum <<<"$file_info"
    setup_colors "$use_color"

    echo -e "${color_path}${fqdn}:${abs_path}${color_reset}"
    echo -e "  ${color_info}Size:${color_reset} $size  ${color_info}Owner:${color_reset} $owner  ${color_info}Perms:${color_reset} $perms"
    echo -e "  ${color_info}Modified:${color_reset} $mtime  ${color_md5}MD5:${color_reset} $md5sum"
}

output_short_mode() {
    local fqdn=$1 file_info=$2
    IFS='|' read -r abs_path _ <<<"$file_info"
    echo "${fqdn}:${abs_path}"
}

output_scp_mode() {
    local user="$1" fqdn="$2" file="$3"
    local abs_path
    abs_path=$(readlink -f "$file")
    echo "${user}@${fqdn}:${abs_path}"
}

output_vim_url_mode() {
    local user="$1" fqdn="$2" file="$3"
    local abs_path
    abs_path=$(readlink -f "$file")
    echo "scp://${user}@${fqdn}//${abs_path}"
}

print_json_output() {
    local entries=()
    for info in "$@"; do
        IFS='|' read -r path perms owner size mtime md5 <<<"$info"
        entries+=("{\"path\":\"$path\",\"perms\":\"$perms\",\"owner\":\"$owner\",\"size\":\"$size\",\"mtime\":\"$mtime\",\"md5\":\"$md5\"}")
    done
    printf '[%s]\n' "${entries[*]// /,}"
}

print_yaml_output() {
    for info in "$@"; do
        IFS='|' read -r path perms owner size mtime md5 <<<"$info"
        cat <<EOF
- path: "$path"
  perms: "$perms"
  owner: "$owner"
  size: "$size"
  mtime: "$mtime"
  md5: "$md5"
EOF
    done
}
