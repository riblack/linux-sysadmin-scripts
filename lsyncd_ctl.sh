#!/bin/bash

set -euo pipefail

# === SOURCE COLOR DEFINITIONS ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLOR_DEF_FILE="$SCRIPT_DIR/load_color_codes.def"
if [[ -f "$COLOR_DEF_FILE" ]]; then
    source "$COLOR_DEF_FILE"
else
    # Fallback if color definitions are missing
    txt_reset=""
    fg_green=""
    fg_red=""
    fg_yellow=""
    fg_cyan=""
    fg_bblue=""
    fg_bwhite=""
    fg_bcyan=""
fi

# === CONFIG ===
CONF_FILE="/etc/lsyncd.conf"
UNIT_FILE="/etc/systemd/system/lsyncd.service"
DEFAULT_CONF="/tmp/default_lsyncd.conf.$$"
LOG_MAIN="/var/log/lsyncd.log"
LOG_STATUS="/var/log/lsyncd-status.log"
EDITOR="${EDITOR:-vim}"

# === SAFE CLEANUP ===
trap_cleanup() {
    # Only remove if /tmp/ file actually exists and $DEFAULT_CONF is non-empty
    if [[ -n "${DEFAULT_CONF:-}" && -f "$DEFAULT_CONF" && "$DEFAULT_CONF" == /tmp/* ]]; then
        rm -f "$DEFAULT_CONF"
    fi
}
trap trap_cleanup EXIT

# === DEFAULT CONFIG CONTENT ===
# This is written to /tmp/default_lsyncd.conf.$$ at runtime
cat >"$DEFAULT_CONF" <<EOF
settings {
    pidfile = "/var/run/lsyncd.pid",
    logfile = "/var/log/lsyncd.log",
    statusFile = "/var/log/lsyncd-status.log",
    statusInterval = 20
}

-- SYNC: home
sync {
    default.rsync,
    source = "/home/richardb/",
    target = "/media/richardb/3d15175f-bb54-4c5c-bec8-60a135737a0d/GROW_PARTITION/",
    rsync = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
        _extra = {
            "--bwlimit=25M",
            "--delete",
            "--recursive"
        },
    }
}

-- SYNC: etc
sync {
    default.rsync,
    source = "/etc/",
    target = "/media/richardb/3d15175f-bb54-4c5c-bec8-60a135737a0d/GROW_PARTITION_ETC/",
    rsync = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
        _extra = {
            "--bwlimit=25M",
            "--delete",
            "--recursive"
        },
    }
}
EOF

# === FUNCTIONS ===

edit_file() {
    sudo "$EDITOR" "$1"
}

show_default_conf() {
    echo "== Default /etc/lsyncd.conf =="
    cat "$DEFAULT_CONF"
}

install_default_conf() {
    read -rp "Install default config to $CONF_FILE? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        sudo cp "$DEFAULT_CONF" "$CONF_FILE"
        echo "Installed default config."
    else
        echo "Aborted."
    fi
}

reload_systemd() {
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
}

restart_lsyncd() {
    echo "Restarting lsyncd..."
    sudo systemctl restart lsyncd.service
    sudo systemctl status lsyncd.service
}

status_lsyncd() {
    sudo systemctl status lsyncd.service
}

view_log() {
    echo -e "${fg_cyan}== Viewing $1 ==${txt_reset}"
    echo -e "Press ENTER to stop viewing the log"
    {
        sudo tail -f "$1" &
        TAIL_PID=$!
        read -r
        kill "$TAIL_PID" 2>/dev/null
        wait "$TAIL_PID" 2>/dev/null
    } </dev/tty
    clear
}

view_journal() {
    sudo journalctl -u lsyncd.service -xe
}

toggle_sync_block() {
    if [[ ! -f "$CONF_FILE" ]]; then
        echo "$CONF_FILE not found."
        return
    fi

    mapfile -t blocks < <(grep -n "^-- SYNC: " "$CONF_FILE" | sed 's/-- SYNC: //')
    if [[ ${#blocks[@]} -eq 0 ]]; then
        echo "No SYNC blocks found. Tag your sync sections like:  -- SYNC: home"
        return
    fi

    echo -e "\n${fg_bblue}== Available SYNC blocks ==${txt_reset}"
    # Display each block, with [enabled]/[disabled] status + source→target
    for i in "${!blocks[@]}"; do
        block="${blocks[$i]}"
        line_start=$(grep -n "^-- SYNC: ${block}" "$CONF_FILE" | cut -d: -f1)
        line_end=$(tail -n +"$line_start" "$CONF_FILE" | grep -n "^}" | head -n1 | cut -d: -f1)
        line_end=$((line_start + line_end - 1))

        # Extract text for that block
        block_text=$(sed -n "${line_start},${line_end}p" "$CONF_FILE")
        if echo "$block_text" | grep -q "^[[:space:]]*--[[:space:]]*sync"; then
            status="${fg_red}[disabled]${txt_reset}"
        else
            status="${fg_green}[enabled]${txt_reset}"
        fi

        # Grab source & target
        source_path=$(echo "$block_text" | grep source | head -n1 | sed 's/.*=\s*"\(.*\)".*/\1/')
        target_path=$(echo "$block_text" | grep target | head -n1 | sed 's/.*=\s*"\(.*\)".*/\1/')

        printf "%2d) %-10s %s %s→ %s%s\n" \
            "$((i + 1))" "$block" "$status" "$fg_yellow" "$source_path" "$txt_reset → $target_path"
    done

    read -rp $'\nSelect sync job to toggle or run: ' index
    index=$((index - 1))
    if [[ $index -lt 0 || $index -ge ${#blocks[@]} ]]; then
        echo "Invalid choice."
        return
    fi

    block_name="${blocks[$index]}"
    line_start=$(grep -n "^-- SYNC: ${block_name}" "$CONF_FILE" | cut -d: -f1)
    line_end=$(tail -n +"$line_start" "$CONF_FILE" | grep -n "^}" | head -n1 | cut -d: -f1)
    line_end=$((line_start + line_end - 1))

    # Ask user if they want to enable, disable, or do a manual rsync
    echo -e "Options for sync block: ${fg_bblue}$block_name${txt_reset}"
    echo "1) Enable"
    echo "2) Disable"
    echo "3) Run one-time rsync now"
    read -rp "Choose action: " action

    case "$action" in
        1)
            echo "Enabling sync: $block_name"
            sudo sed -i "${line_start},${line_end}s/^[[:space:]]*--[[:space:]]*//" "$CONF_FILE"
            restart_lsyncd
            ;;
        2)
            echo "Disabling sync: $block_name"
            sudo sed -i "${line_start},${line_end}s/^[[:space:]]*/-- /" "$CONF_FILE"
            restart_lsyncd
            ;;
        3)
            source_path=$(sed -n "${line_start},${line_end}p" "$CONF_FILE" | grep source | head -n1 | sed 's/.*=\s*"\(.*\)".*/\1/')
            target_path=$(sed -n "${line_start},${line_end}p" "$CONF_FILE" | grep target | head -n1 | sed 's/.*=\s*"\(.*\)".*/\1/')
            echo -e "\nRunning: rsync -aHAX --delete \"$source_path\" \"$target_path\""
            rsync -aHAX --delete "$source_path" "$target_path"
            ;;
        *)
            echo "Invalid action."
            ;;
    esac
}

sync_status_check() {
    echo -e "\n${fg_bcyan}== Sync Status Check ==${txt_reset}"
    awk '
        BEGIN { skip = 0; name = ""; source = ""; target = "" }
        /^\s*-- SYNC:/ { name = $0; gsub(/-- SYNC: /, "", name); skip = 0 }
        /^\s*--/ { next }
        skip { next }
        /sync\s*{/ { block = 1 }
        /source\s*=/ { gsub(/[",]/, "", $3); source = $3 }
        /target\s*=/ { gsub(/[",]/, "", $3); target = $3 }
        /^}/ {
            if (source && target) {
                printf "\n🔄 SYNC: %s\n", name
                printf "   %s → %s\n", source, target
                cmd = "rsync -aHAXn --delete \"" source "/\" \"" target "/\""
                while ((cmd | getline line) > 0) {
                    if (line ~ /^[^ ]/) { print "   ❗️ " line; found=1 }
                }
                close(cmd)
                if (!found) {
                    print "   ✅ Already in sync."
                }
                found = 0
            }
            block = 0; source = ""; target = ""
        }
    ' "$CONF_FILE"
}

# === MAIN MENU ===

show_menu() {
    cat <<EOF
${fg_bwhite}Lsyncd Control Menu${txt_reset}

 1) Show default lsyncd.conf
 2) Install default lsyncd.conf
 3) Edit lsyncd.conf
 4) Edit systemd unit file
 5) Reload systemd + restart lsyncd
 6) Restart lsyncd
 7) Start lsyncd
 8) Stop lsyncd
 9) Status of lsyncd
10) View lsyncd.log
11) View lsyncd-status.log
12) View journal logs
13) Enable/Disable/run sync blocks
14) Check sync status (dry-run)
 q) Quit
EOF
}

while true; do
    show_menu
    read -rp "Choose an option: " choice
    case "$choice" in
        1) show_default_conf ;;
        2) install_default_conf ;;
        3) edit_file "$CONF_FILE" ;;
        4) edit_file "$UNIT_FILE" ;;
        5)
            reload_systemd
            restart_lsyncd
            ;;
        6) restart_lsyncd ;;
        7) sudo systemctl start lsyncd.service ;;
        8) sudo systemctl stop lsyncd.service ;;
        9) status_lsyncd ;;
        10) view_log "$LOG_MAIN" ;;
        11) view_log "$LOG_STATUS" ;;
        12) view_journal ;;
        13) toggle_sync_block ;;
        14) sync_status_check ;;
        q | Q)
            echo "Bye!"
            break
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
    echo
done
