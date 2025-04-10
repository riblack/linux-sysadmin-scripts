#!/usr/bin/env bash
#
# mpd_control.sh
#
# A Bash script to manage MPD (Music Player Daemon) in both user mode and system mode.

###############################################################################
# CONFIGURATION                                                               #
###############################################################################

# Edit these if you have different service names or log file paths.
USER_SERVICE_NAME="mpd"
SYSTEM_SERVICE_NAME="mpd"
USER_LOG_FILE="$HOME/.config/mpd/log"  # Typical user-mode MPD log (if enabled)
SYSTEM_LOG_FILE="/var/log/mpd/mpd.log" # Typical system log (if configured)

###############################################################################
# FUNCTIONS                                                                   #
###############################################################################

usage() {
  echo "Usage: $0 [action]"
  echo
  echo "If no action is given, an interactive menu is presented."
  echo
  echo "Available actions:"
  echo "  update                Update MPD library (user mode)"
  echo "  enable-user           Enable user-mode MPD service"
  echo "  disable-user          Disable user-mode MPD service"
  echo "  enable-system         Enable system-wide MPD service"
  echo "  disable-system        Disable system-wide MPD service"
  echo "  start-user            Start user-mode MPD service"
  echo "  stop-user             Stop user-mode MPD service"
  echo "  restart-user          Restart user-mode MPD service"
  echo "  status-user           Show user-mode MPD status"
  echo "  journal-user          Show user-mode MPD journal logs"
  echo "  logs-user             Show user-mode MPD log file"
  echo "  start-system          Start system-wide MPD service"
  echo "  stop-system           Stop system-wide MPD service"
  echo "  restart-system        Restart system-wide MPD service"
  echo "  status-system         Show system-wide MPD status"
  echo "  journal-system        Show system-wide MPD journal logs"
  echo "  logs-system           Show system-wide MPD log file"
  echo
  echo "Example: $0 start-user"
}

#--- Actions ---

update_mpd_library() {
  echo "Updating MPD library (user mode)..."
  mpc update
}

enable_mpd_user() {
  echo "Enabling user-mode MPD service..."
  systemctl --user enable "$USER_SERVICE_NAME"
}

disable_mpd_user() {
  echo "Disabling user-mode MPD service..."
  systemctl --user disable "$USER_SERVICE_NAME"
}

enable_mpd_system() {
  echo "Enabling system-wide MPD service..."
  sudo systemctl enable "$SYSTEM_SERVICE_NAME"
}

disable_mpd_system() {
  echo "Disabling system-wide MPD service..."
  sudo systemctl disable "$SYSTEM_SERVICE_NAME"
}

start_mpd_user() {
  echo "Starting user-mode MPD service..."
  systemctl --user start "$USER_SERVICE_NAME"
}

stop_mpd_user() {
  echo "Stopping user-mode MPD service..."
  systemctl --user stop "$USER_SERVICE_NAME"
}

restart_mpd_user() {
  echo "Restarting user-mode MPD service..."
  systemctl --user restart "$USER_SERVICE_NAME"
}

status_mpd_user() {
  echo "User-mode MPD service status:"
  systemctl --user status "$USER_SERVICE_NAME"
}

journal_mpd_user() {
  echo "User-mode MPD service journal (press q to exit):"
  journalctl --user -u "$USER_SERVICE_NAME" -e
}

logs_mpd_user() {
  echo "Showing user-mode MPD log file: $USER_LOG_FILE"
  if [[ -f "$USER_LOG_FILE" ]]; then
    less "$USER_LOG_FILE"
  else
    echo "Log file not found: $USER_LOG_FILE"
  fi
}

start_mpd_system() {
  echo "Starting system-wide MPD service..."
  sudo systemctl start "$SYSTEM_SERVICE_NAME"
}

stop_mpd_system() {
  echo "Stopping system-wide MPD service..."
  sudo systemctl stop "$SYSTEM_SERVICE_NAME"
}

restart_mpd_system() {
  echo "Restarting system-wide MPD service..."
  sudo systemctl restart "$SYSTEM_SERVICE_NAME"
}

status_mpd_system() {
  echo "System-wide MPD service status:"
  sudo systemctl status "$SYSTEM_SERVICE_NAME"
}

journal_mpd_system() {
  echo "System-wide MPD service journal (press q to exit):"
  journalctl -u "$SYSTEM_SERVICE_NAME" -e
}

logs_mpd_system() {
  echo "Showing system-wide MPD log file: $SYSTEM_LOG_FILE"
  if [[ -f "$SYSTEM_LOG_FILE" ]]; then
    sudo less "$SYSTEM_LOG_FILE"
  else
    echo "Log file not found: $SYSTEM_LOG_FILE"
  fi
}

#--- Interactive Menu ---

menu() {
  while true; do
    echo "================================="
    echo "    MPD Control Menu"
    echo "================================="
    echo "1) Update MPD Library (user mode)"
    echo "2) Enable MPD (user)"
    echo "3) Disable MPD (user)"
    echo "4) Enable MPD (system)"
    echo "5) Disable MPD (system)"
    echo "6) Start MPD (user)"
    echo "7) Stop MPD (user)"
    echo "8) Restart MPD (user)"
    echo "9) Start MPD (system)"
    echo "10) Stop MPD (system)"
    echo "11) Restart MPD (system)"
    echo "12) Status (user)"
    echo "13) Status (system)"
    echo "14) Journal (user)"
    echo "15) Journal (system)"
    echo "16) View log file (user)"
    echo "17) View log file (system)"
    echo "q) Quit"
    echo "---------------------------------"
    read -rp "Select an option: " choice
    case "$choice" in
      1)  update_mpd_library ;;
      2)  enable_mpd_user ;;
      3)  disable_mpd_user ;;
      4)  enable_mpd_system ;;
      5)  disable_mpd_system ;;
      6)  start_mpd_user ;;
      7)  stop_mpd_user ;;
      8)  restart_mpd_user ;;
      9)  start_mpd_system ;;
      10) stop_mpd_system ;;
      11) restart_mpd_system ;;
      12) status_mpd_user ;;
      13) status_mpd_system ;;
      14) journal_mpd_user ;;
      15) journal_mpd_system ;;
      16) logs_mpd_user ;;
      17) logs_mpd_system ;;
      q|Q)
          echo "Exiting."
          break
          ;;
      *)
          echo "Invalid choice. Please try again."
          ;;
    esac
    echo
    # Wait for user to press [Enter] before refreshing menu
    read -rp "Press Enter to continue..." dummy
  done
}

###############################################################################
# MAIN LOGIC                                                                  #
###############################################################################

# If an argument is given, treat it as a command; otherwise, go to the menu.
case "$1" in
  update)           update_mpd_library ;;
  enable-user)      enable_mpd_user ;;
  disable-user)     disable_mpd_user ;;
  enable-system)    enable_mpd_system ;;
  disable-system)   disable_mpd_system ;;
  start-user)       start_mpd_user ;;
  stop-user)        stop_mpd_user ;;
  restart-user)     restart_mpd_user ;;
  status-user)      status_mpd_user ;;
  journal-user)     journal_mpd_user ;;
  logs-user)        logs_mpd_user ;;
  start-system)     start_mpd_system ;;
  stop-system)      stop_mpd_system ;;
  restart-system)   restart_mpd_system ;;
  status-system)    status_mpd_system ;;
  journal-system)   journal_mpd_system ;;
  logs-system)      logs_mpd_system ;;
  ""|help|--help|-h) # No argument, or help → show the menu
      menu
      ;;
  *)
      echo "Error: Unknown command '$1'"
      usage
      exit 1
      ;;
esac

