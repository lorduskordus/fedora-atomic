#!/usr/bin/env bash

# Apply a fix for Flatpaked Vulkan apps trying to use NVIDIA

set -euo pipefail

echo "Apply a fix for Flatpaked Vulkan apps trying to use NVIDIA"

if [[ "${IMAGE_NAME}" != *"nvidia"* ]]; then
    echo "- Not a NVIDIA image. Exiting."
    exit 0
fi

cat << 'EOF' > /usr/lib/systemd/system/fix-flatpak-nvidia-vulkan.service
[Unit]
Description=Fix Flatpaked Vulkan apps trying to use NVIDIA
After=graphical.target

[Service]
Type=oneshot
ExecStart=/usr/bin/vulkaninfo

[Install]
WantedBy=graphical.target
EOF

systemctl -f enable fix-flatpak-nvidia-vulkan.service

echo "- Done."
