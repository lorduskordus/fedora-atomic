#!/usr/bin/env bash

# Installs the latest 'AppGrid' Plasma Applet from Github

set -euo pipefail

echo -e "\e[1m\e[38;5;214mInstalling the latest 'AppGrid' Plasma Applet from Github\e[0m"

URL="https://github.com/xarbit/plasma6-applet-appgrid"

# Get latest release version tag
VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} \
    ${URL}/releases/latest) \
    | cut -d'v' -f2-)

# Install
dnf5 -y install \
    ${URL}/releases/download/v${VER}/plasma-applet-appgrid-${VER}-1.fc$(rpm -E %fedora).x86_64.rpm
