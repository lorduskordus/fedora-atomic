#!/usr/bin/env bash

# Installs a specified kernel and NVIDIA drivers if needed

set -euo pipefail

install-kernel() {
    echo "- Replacing kernel"

    dnf5 -y remove kernel-{core,modules,modules-core,modules-extra,tools,tools-libs}

    skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/"${AKMODS_TYPE}":"${AKMODS_FLAVOR}"-"$(rpm -E %fedora)" dir:/tmp/akmods-rpms
    AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json | cut -d : -f 2)
    tar -xvzf /tmp/akmods-rpms/"$AKMODS_TARGZ" -C /tmp/
    mv /tmp/rpms/* /tmp/akmods-rpms/
    # NOTE: kernel-rpms should auto-extract into correct location

    dnf5 -y install \
      /tmp/kernel-rpms/kernel-[0-9]*.rpm \
      /tmp/kernel-rpms/kernel-core-*.rpm \
      /tmp/kernel-rpms/kernel-modules-*.rpm

    dnf5 versionlock add kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
}

install-nvidia-drivers () {
    echo "- Installing NVIDIA drivers"
    export IMAGE_NAME=$(awk -F'/' '{print $3}' <<< "${BASE_IMAGE}" | cut -d'-' -f1)
    curl -s "https://raw.githubusercontent.com/ublue-os/main/refs/heads/main/build_files/nvidia-install.sh" | bash
}

build-initramfs () {
    echo "- Building initramfs"
    curl -s "https://raw.githubusercontent.com/ublue-os/main/refs/heads/main/build_files/initramfs.sh" | bash
}

install () {
    AKMODS_FLAVOR=${1:-"main"}

    INFO_STRING="Installing kernel (${AKMODS_FLAVOR})"

    if [[ "${IMAGE_NAME}" == *"nvidia-closed"* ]]; then
        INFO_STRING+=" and NVIDIA drivers (closed)"
        AKMODS_TYPE="akmods-nvidia"
        NEEDS_NVIDIA=1
    elif [[ "${IMAGE_NAME}" == *"nvidia"* ]]; then
        INFO_STRING+=" and NVIDIA drivers (open)"
        AKMODS_TYPE="akmods-nvidia-open"
        NEEDS_NVIDIA=1
    else
        AKMODS_TYPE="akmods"
        NEEDS_NVIDIA=0
    fi

    echo "${INFO_STRING}"

    install-kernel

    if [[ "${NEEDS_NVIDIA}" -eq 1 ]]; then
        install-nvidia-drivers
    fi

    build-initramfs
}

install "coreos-stable"
