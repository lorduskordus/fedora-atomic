#!/usr/bin/env bash

# Sets up ublue's 'nvidia-flatpak-runtime-sync' script & service,
# that should keep the Flatpak NVIDIA runtime version in sync with
# the system one, preventing app breakage.

set -euo pipefail

SCRIPT_NAME="ublue-nvidia-flatpak-runtime-sync"
SERVICE_NAME="ublue-nvidia-flatpak-runtime-sync.service"

SCRIPT_DST="/usr/libexec/${SCRIPT_NAME}"
SERVICE_DST="/usr/lib/systemd/system/${SERVICE_NAME}"

SCRIPT_URL="https://raw.githubusercontent.com/projectbluefin/common/refs/heads/main/system_files/nvidia${SCRIPT_DST}"
SERVICE_URL="https://raw.githubusercontent.com/projectbluefin/common/refs/heads/main/system_files/nvidia${SERVICE_DST}"

echo -e "\e[1m\e[38;5;214mInstalling 'nvidia-flatpak-runtime-sync' script & service\e[0m"

# Download script & ensure it's executable
curl -fLs --create-dirs ${SCRIPT_URL} -o ${SCRIPT_DST}
chmod +x ${SCRIPT_DST}

# Download service & enable it
curl -fLs --create-dirs ${SERVICE_URL} -o ${SERVICE_DST}
systemctl enable ${SCRIPT_NAME}
