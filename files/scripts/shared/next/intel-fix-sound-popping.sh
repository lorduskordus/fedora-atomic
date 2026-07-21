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
intel-disable-powersave
EOF

TUNED_OVERRIDE="${TUNED_DIR}/profiles/intel-disable-powersave"
mkdir -p "${TUNED_OVERRIDE}"
cat << 'EOF' > "${TUNED_OVERRIDE}/tuned.conf"
[audio]
timeout=0
EOF
