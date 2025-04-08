#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

fix_yt_dlp_cookies() {
    echo "[+] Installing system dependencies..."
    sudo apt install -y python3-dbus python3-gi

    echo "[+] Installing secretstorage Python package with override..."
    python3 -m pip install --break-system-packages secretstorage

    echo "[+] Updating yt-dlp (if installed via pip)..."
    yt-dlp -U

    echo "[✓] All done. You can now use yt-dlp with Chrome cookies:"
    echo "    yt-dlp --cookies-from-browser chrome <url>"
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
