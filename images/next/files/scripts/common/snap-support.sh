#!/usr/bin/env bash

# Creates a '/var/lib/snapd/snap' directory and a symlink at '/snap'
# pointing to it, so that the Snap package manager can be used
#
# Doesn't work fully because of this: https://snapcraft.io/docs/home-outside-home

set -euo pipefail

SNAP_DIR="/var/lib/snapd/snap"
SNAP_CLASSIC_DIR="/snap"

echo "Enabling Snap package manager support"

mkdir -p ${SNAP_DIR}
ln -s ${SNAP_DIR} ${SNAP_CLASSIC_DIR}
