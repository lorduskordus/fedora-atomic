#!/usr/bin/env bash

# Install Docker & Podman wrappers to enable container usage inside VS Code

set -euo pipefail

DEST_PATH="/usr/bin"
WRAPPER_PODMAN="podman-host"
WRAPPER_DOCKER="docker-host"
URL="https://raw.githubusercontent.com/89luca89/distrobox/main/extras"

echo "Installing container wrappers for VS Code usage"

# Podman
if rpm -q podman &> /dev/null; then
    echo "- Podman is installed, installing wrapper"

    URL_PODMAN="${URL}/${WRAPPER_PODMAN}"
    if wget -q "${URL_PODMAN}" -O "${DEST_PATH}/${WRAPPER_PODMAN}"; then
        chmod 755 "${DEST_PATH}/${WRAPPER_PODMAN}"
        echo "  - Successfuly installed '"${WRAPPER_PODMAN}"'"
    else
        echo "  - Failed to install '"${WRAPPER_PODMAN}"'"
        exit 1
    fi

else
    echo "- Podman is not installed, skipping '"${WRAPPER_PODMAN}"'"
fi

# Docker
if rpm -q docker-ce &> /dev/null; then
    echo "- Docker is installed, installing wrapper"

    URL_DOCKER="${URL}/${WRAPPER_DOCKER}"
    if wget -q "${URL_DOCKER}" -O "${DEST_PATH}/${WRAPPER_DOCKER}"; then
        chmod 755 "${DEST_PATH}/${WRAPPER_DOCKER}"
        echo "  - Successfuly installed '"${WRAPPER_DOCKER}"'"
    else
        echo "  - Failed to install '"${WRAPPER_DOCKER}"'"
        exit 1
    fi

else
    echo "- Docker is not installed, skipping '"${WRAPPER_DOCKER}"'"
fi
