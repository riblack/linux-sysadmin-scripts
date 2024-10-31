#!/usr/bin/env bash

alias lss >/dev/null 2>&1 && unalias lss
. "${HOME}/.config/lss/lss.conf"

# Main function to navigate to the script directory
lss ()
{

    # Source configuration if the variable is not already set
    [ -n "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" ] || . "${HOME}/.config/lss/lss.conf"
    [ -n "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" ] || { echo "ERROR, lss settings not loaded."; return 1; }

    # Check if the directory exists; install if not
    if [ -d "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" ]; then
        cd "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" || {
            echo "Could not change to ${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}"
            return 1
        }
    else
        echo "Linux Sysadmin Scripts not found. Initiating installation..."
        . ./install_lss.sh && install_lss
        cd "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" || return 1
    fi
}

# Source footer if it exists
[ -f "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}/bash_footer.template.live" ] && source "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}/bash_footer.template.live" || echo "Footer template missing. Skipping..."

