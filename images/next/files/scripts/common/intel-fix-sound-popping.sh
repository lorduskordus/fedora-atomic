#!/usr/bin/env bash

# Fixes sound pops caused by Intel powersave

set -euo pipefail

echo "Fixing sound popping caused by Intel powersave by disabling it"

MODPROBE_DIR="/etc/modprobe.d"
mkdir -p "${MODPROBE_DIR}"
cat << 'EOF' > "${MODPROBE_DIR}/intel-disable-powersave.conf"
# Intel's power_save causes audio popping
#   - This disables power_save completely
#   - Tuned profiles can alter this value as well

options snd-hda-intel power_save=0 power_save_controller=N
EOF

TUNED_DIR="/etc/tuned"
mkdir -p "${TUNED_DIR}"
cat << 'EOF' > "${TUNED_DIR}/post_loaded_profile"
overrides
EOF

TUNED_OVERRIDES="${TUNED_DIR}/profiles/overrides"
mkdir -p "${TUNED_OVERRIDES}"
cat << 'EOF' > "${TUNED_OVERRIDES}/tuned.conf"
[audio]
timeout=0
EOF
