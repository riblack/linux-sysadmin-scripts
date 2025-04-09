#!/bin/bash
# Usage: ./how_installed.sh <program_name>
# Description: Attempts to reverse engineer how a program was installed.

set -euo pipefail

program="${1:-}"
[[ -z "$program" ]] && { echo "Usage: $0 <program_name>"; exit 1; }

echo "🔍 Checking installation method for: $program"
echo "==========================================="

# 1. Locate binary
bin_path=$(command -v "$program" || true)
if [[ -z "$bin_path" ]]; then
    echo "❌ Command '$program' not found in PATH."
    exit 1
fi

echo "📌 Found binary at: $bin_path"

# 2. Check if it's part of an APT package
if pkg=$(dpkg -S "$bin_path" 2>/dev/null); then
    pkg_name=$(cut -d: -f1 <<< "$pkg")
    echo "✅ APT package: $pkg_name"

    echo "📦 APT package details:"
    apt policy "$pkg_name" || echo "  (Policy not found)"
    echo
    echo "🔎 APT source:"
    grep -r "^deb " /etc/apt/sources.list /etc/apt/sources.list.d/ \
        | grep -i "$pkg_name" || echo "  (Not explicitly found — might be main/universe/multiverse)"
else
    echo "❌ Not found in APT package database."
fi

# 3. Check if installed via Snap
if command -v snap >/dev/null && snap list | grep -q "^$program\b"; then
    echo "✅ Installed via Snap:"
    snap list | grep "^$program\b"
else
    echo "❌ Not installed via Snap."
fi

# 4. Check if installed via Flatpak
if command -v flatpak >/dev/null && flatpak list | grep -qi "$program"; then
    echo "✅ Installed via Flatpak:"
    flatpak list | grep -i "$program"
else
    echo "❌ Not installed via Flatpak."
fi

# 5. Check if installed from a PPA
if grep -r "^deb " /etc/apt/sources.list.d/ | grep -qi "ppa"; then
    echo "🔧 Found PPAs configured:"
    grep -r "^deb " /etc/apt/sources.list.d/ | grep -i "ppa"
else
    echo "ℹ️ No PPAs configured."
fi

# 6. Check if it’s a Python or shell script (manual install)
first_line=$(head -n1 "$bin_path" 2>/dev/null || echo "")
case "$first_line" in
    "#!"*/python* )
        echo "🧪 Appears to be a Python script: $first_line"
        ;;
    "#!"*/bash* | "#!"*/sh* )
        echo "🐚 Appears to be a shell script: $first_line"
        ;;
    *ELF* )
        echo "🔧 Compiled binary (likely system or manually built)."
        ;;
    * )
        echo "ℹ️ Unknown file type: $first_line"
        ;;
esac

# 7. Check for /usr/local or other manual install indicators
if [[ "$bin_path" == /usr/local/* ]]; then
    echo "⚠️ Located in /usr/local — likely installed manually (make install, pip, etc)."
fi

echo "==========================================="
echo "✅ Inspection complete."

