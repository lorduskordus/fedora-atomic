#!/usr/bin/env bash

# Updates KDE Plasma to the latest version from @kdesig/kde-final COPR

set -euo pipefail

echo "Updating KDE Plasma to the latest version from @kdesig/kde-final COPR"

dnf5 copr enable -y @kdesig/kde-final && dnf5 update -y
