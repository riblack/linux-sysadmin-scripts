#!/bin/bash
# search_dhcp_backups.sh - Find presence of a MAC/IP string across DHCP backup files

set -euo pipefail

# Color setup
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

read -rp "🔍 Enter the MAC/IP string to search for: " search_string
echo

# Find and sort files by mod time, newest last
mapfile -t files < <(find . -type f -printf "%T@ %p\n" | sort -n | awk '{print $2}')

if [[ ${#files[@]} -eq 0 ]]; then
  echo "❌ No files found to search."
  exit 1
fi

found_any=false

for file in "${files[@]}"; do
  timestamp=$(stat -c '%y' "$file")
  if grep -qi "$search_string" "$file"; then
    echo -e "${GREEN}✔ Found${RESET} in ${BLUE}$file${RESET} at ${YELLOW}$timestamp${RESET}"
    found_any=true
  else
    echo -e "${RED}✘ Not found${RESET} in ${BLUE}$file${RESET} at ${YELLOW}$timestamp${RESET}"
  fi
done

if ! $found_any; then
  echo -e "\n${RED}🔎 '$search_string' was not found in any backup.${RESET}"
fi

