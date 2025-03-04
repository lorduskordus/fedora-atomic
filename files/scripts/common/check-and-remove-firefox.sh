#!/usr/bin/env bash

# Checks if firefox & firefox-langpacks is installed and removes them
#
# Fixes builds on images that don't include firefox while allowing for cleaner config

set -euo pipefail

echo "Firefox RPM status:"
if ! rpm -q firefox &> /dev/null; then
    echo "- Not installed"
else
    echo "- Installed, removing"
    dnf5 -y remove \
        firefox \
        firefox-langpacks
fi
