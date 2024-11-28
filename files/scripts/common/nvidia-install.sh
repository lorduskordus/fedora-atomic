#!/usr/bin/env bash

# Installs nvidia drivers.

set -euo pipefail

export IMAGE_NAME=$(echo "${BASE_IMAGE}" | awk -F'/' '{print $3}' | cut -d'-' -f1)
export KERNEL_FLAVOR="coreos-stable"

curl -s https://raw.githubusercontent.com/ublue-os/hwe/refs/heads/main/nvidia-install.sh | bash
curl -s https://raw.githubusercontent.com/ublue-os/hwe/refs/heads/main/build-initramfs.sh | bash
