#!/usr/bin/env bash

# Removes 60-custom.just from ublue's justfile to separate
# ublue and image justfiles.

set -euo pipefail

FILE="/usr/share/ublue-os/justfile"
LINE_TO_REMOVE='import "/usr/share/ublue-os/just/60-custom.just"'

echo "Removing '60-custom.just' import line from ublue's justfile"

if grep -Fxq "$LINE_TO_REMOVE" "$FILE"; then
    sed -i "\|^$LINE_TO_REMOVE\$|d" "$FILE"
    echo "- Line removed successfully."
else
    echo "- Line not found. No changes made."
fi
