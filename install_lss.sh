#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_lss ()
{
    # Minimal configuration defined here
    INITIAL_MINIMAL_SETTINGS=$(cat <<-'EOF_SETTINGS'
	LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_DIRECTORY="${HOME}/.config/lss/"
	LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_FILE="${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_DIRECTORY%/}/lss.conf"
	GIT_DIRECTORY="${HOME}/git/"
	LINUX_SYSADMIN_SCRIPTS_DIRECTORY="${GIT_DIRECTORY%/}/linux-sysadmin-scripts"
EOF_SETTINGS
    )

    # Source minimal settings
    eval "${INITIAL_MINIMAL_SETTINGS}"

    # Create config directory and file if needed
    mkdir -p "${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_DIRECTORY}"
    [ -f "${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_FILE}" ] || echo "${INITIAL_MINIMAL_SETTINGS}" > "${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_FILE}"

    # Populate missing entries in the config file
    while IFS= read -r CONFIG_LINE; do
        ENTRY_KEY="${CONFIG_LINE%%=*}"
        grep -q "^${ENTRY_KEY}=" "${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_FILE}" || echo "${CONFIG_LINE}" >> "${LINUX_SYSADMIN_SCRIPTS_CONFIGURATION_FILE}"
    done <<< "${INITIAL_MINIMAL_SETTINGS}"

    # Create git directory if it doesn't exist
    mkdir -p "${GIT_DIRECTORY}"

    # Clone Linux Sysadmin Scripts if it's not installed
    if [ -d "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY}" ]; then
        echo "Linux Sysadmin Scripts is already installed ..."
    else
        echo "Installing Linux Sysadmin Scripts ..."
        cd "${GIT_DIRECTORY}" || return 1
        git clone https://github.com/riblack/linux-sysadmin-scripts.git || return 1

        # Ensure function for easy access
        grep -q "lss.sh" ~/.bash_functions || echo ". \"${LINUX_SYSADMIN_SCRIPTS_DIRECTORY%/}/lss.sh\"" >> ~/.bash_functions

        # Make sure functions load on startup
        grep -q ".bash_functions" ~/.bashrc || cat <<-'EOF_BASH_FUNCTIONS' >> ~/.bashrc

# Function definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_functions, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

EOF_BASH_FUNCTIONS

        echo "Installation complete."

        . "${LINUX_SYSADMIN_SCRIPTS_DIRECTORY%/}/lss.sh"
	lss
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

