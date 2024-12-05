#!/usr/bin/env bash

attempt_conversion_from_ntp_to_chrony ()
{
    read -p "Not actually working yet - Ctrl+c to abort"
    dpkg -l | grep ntp
    sudo apt remove ntp --purge
    sudo apt remove systemd-timesyncd --purge
    sudo apt install chrony
    sudo systemctl enable chrony
    sudo systemctl start chrony
    sudo systemctl status chrony
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

