#!/usr/bin/env bash
#
# check_temp.sh — Interactive NVMe/SSD temperature checker
# Works with CLI and GUI tools. Default device: /dev/nvme0n1

DEFAULT_DEV="/dev/nvme0n1"

echo "Would you like to check your drive temperature via CLI or GUI?"
read -rp "Enter 'cli' or 'gui': " method

if [[ "$method" == "cli" ]]; then
  echo "Which CLI tool would you like to use?"
  echo "Options: nvme-cli | smartctl | btop | hddtemp"
  read -rp "Tool: " tool

  if [[ "$tool" != "btop" ]]; then
    read -rp "Enter device path [default: $DEFAULT_DEV]: " devpath
    devpath="${devpath:-$DEFAULT_DEV}"
  fi

  case "$tool" in
    nvme-cli)
      echo "Running nvme-cli SMART log on $devpath..."
      sudo nvme smart-log "$devpath"
      ;;
    smartctl)
      echo "Running smartctl on $devpath..."
      sudo smartctl -A "$devpath"
      ;;
    btop)
      echo "Launching btop (terminal UI)..."
      btop
      ;;
    hddtemp)
      echo "Running hddtemp on $devpath..."
      sudo hddtemp "$devpath"
      ;;
    *)
      echo "Unknown CLI tool: $tool"
      exit 1
      ;;
  esac

elif [[ "$method" == "gui" ]]; then
  echo "Which GUI tool would you like to launch?"
  echo "Options: gnome-disks | psensor"
  read -rp "Tool: " guitool

  case "$guitool" in
    gnome-disks)
      echo "Launching GNOME Disks..."
      gnome-disks &
      ;;
    psensor)
      echo "Launching psensor..."
      psensor &
      ;;
    *)
      echo "Unknown GUI tool: $guitool"
      exit 1
      ;;
  esac

else
  echo "Invalid choice. Please run again and choose 'cli' or 'gui'."
  exit 1
fi

