#!/usr/bin/env bash

# CoreOS kernel post-install required for NVIDIA

set -euo pipefail

echo "CoreOS kernel post-install script"
if [[ ! "${IMAGE_NAME}" =~ nvidia ]]; then
    echo "- NORMAL image, no action needed"
    exit 0
else
    echo "- NVIDIA image, installing drivers"
fi

export IMAGE_NAME=$(awk -F'/' '{print $3}' <<< "${BASE_IMAGE}" | cut -d'-' -f1)
export KERNEL_FLAVOR="coreos-stable"

curl -s https://raw.githubusercontent.com/ublue-os/hwe/refs/heads/main/nvidia-install.sh | bash
curl -s https://raw.githubusercontent.com/ublue-os/hwe/refs/heads/main/build-initramfs.sh | bash
