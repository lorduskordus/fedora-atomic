#!/usr/bin/env bash

# Kernel post-install script required for NVIDIA

set -euo pipefail

echo "Kernel post-install script"
if [[ ! "${IMAGE_NAME}" =~ nvidia ]]; then
    echo "- NORMAL image, no action needed"
    exit 0
else
    echo "- NVIDIA image, installing drivers"
fi

export IMAGE_NAME=$(awk -F'/' '{print $3}' <<< "${BASE_IMAGE}" | cut -d'-' -f1)

curl -s https://raw.githubusercontent.com/ublue-os/hwe/refs/heads/main/nvidia-install.sh | bash
