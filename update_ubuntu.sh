#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

update_ubuntu() {

    package=apt
    dpkg -l $package | grep -qw ^ii && {
        sudo apt-get -y update || return 1
        apt list --upgradable
        sudo apt-get -y upgrade || return 1
        sudo apt --fix-broken install
        sudo apt-get -y dist-upgrade || return 1
        # sudo apt-get -y autoremove --dry-run
        sudo apt-get -y autoremove || return 1
        sudo apt-get autoclean
    }

    package=aptitude
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        sudo aptitude -y update || return 1
        sudo aptitude -y upgrade || return 1
    }

    package=snapd
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        sudo killall snap-store
        sudo snap refresh || return 1
    }

    package=fwupd
    # dpkg -l $package | grep -qw ^ii || apt-get -y install $package
    dpkg -l $package | grep -qw ^ii && {
        fwupdmgr get-devices >/dev/null || return 1
        fwupdmgr refresh --force || return 1
        fwupdmgr get-updates || return 1
        fwupdmgr -y update || return 1
        # fwupdmgr update -y --no-reboot-check

        ### # Other fwupdmgr commands
        ### fwupdmgr --help
        ### fwupdmgr --version
        ### # Alias to fwupdmgr update
        ### fwupdmgr upgrade
    }

    command -v yt-dlp && sudo yt-dlp -U

    #     Fix if repository changes some of its metadata:
    #
    # E: Repository 'https://pkgs.zabbly.com/incus/lts-6.0 noble InRelease' changed its 'Origin' value from '. noble' to 'pkgs.zabbly.com'
    # E: Repository 'https://pkgs.zabbly.com/incus/lts-6.0 noble InRelease' changed its 'Label' value from '. noble' to 'incus-lts-6.0'
    # N: This must be accepted explicitly before updates for this repository can be applied. See apt-secure(8) manpage for details.
    # E: Repository 'https://pkgs.zabbly.com/incus/stable noble InRelease' changed its 'Origin' value from '. noble' to 'pkgs.zabbly.com'
    # E: Repository 'https://pkgs.zabbly.com/incus/stable noble InRelease' changed its 'Label' value from '. noble' to 'incus-stable'
    # N: This must be accepted explicitly before updates for this repository can be applied. See apt-secure(8) manpage for details.
    #
    # This happens because the repository you’re using has changed some of its metadata (“Origin” and “Label”). By default, APT won’t automatically trust a repository if these fields change after you’ve added it. You must explicitly accept the changes before APT proceeds.
    #
    # The quickest fix is to run apt-get update (or apt update on newer distributions) with the --allow-releaseinfo-change flags. For example:
    #
    sudo apt-get update \
        --allow-releaseinfo-change-origin \
        --allow-releaseinfo-change-label

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi
