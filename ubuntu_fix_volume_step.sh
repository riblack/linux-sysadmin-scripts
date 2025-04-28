#!/bin/bash

gsettings get org.gnome.settings-daemon.plugins.media-keys volume-step
# 6
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 1
gsettings get org.gnome.settings-daemon.plugins.media-keys volume-step
# 1

