#!/usr/bin/env bash
#
# save this file as check_temp.sh, then `chmod +x check_temp.sh`
# Usage: ./check_temp.sh

echo "Would you like to check your drive temperature via CLI or GUI?"
read -rp "Enter 'cli' or 'gui': " method

if [[ "$method" == "cli" ]]; then
  echo "Which CLI tool would you like to use?"
  echo "Options: nvme-cli | smartctl | btop | hddtemp"
  read -rp "Tool: " tool

  # For CLI tools that need a device path:
  if [[ "$tool" != "btop" ]]; then
    echo "Enter your device path (e.g., /dev/nvme0n1 or /dev/sda):"
    read -rp "Device path: " devpath
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
      echo "Running btop (terminal UI)..."
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
      gnome-disks
      ;;
    psensor)
      echo "Launching psensor..."
      psensor
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

