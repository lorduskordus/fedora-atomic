#!/usr/bin/env bash

# Kernel post-install script

set -euo pipefail

build-initramfs () {
    echo "- Building initramfs"
    curl -s "https://raw.githubusercontent.com/ublue-os/main/refs/heads/main/build_files/initramfs.sh" | bash
}

install-nvidia-drivers () {
    echo "- Installing drivers"
    export IMAGE_NAME=$(awk -F'/' '{print $3}' <<< "${BASE_IMAGE}" | cut -d'-' -f1)
    curl -s "https://raw.githubusercontent.com/ublue-os/main/refs/heads/main/build_files/nvidia-install.sh" | bash
}

echo "Kernel post-install script"

if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
    echo "Image: NVIDIA"
    install-nvidia-drivers
    build-initramfs
else
    echo "Image: MAIN"
    build-initramfs
fi
