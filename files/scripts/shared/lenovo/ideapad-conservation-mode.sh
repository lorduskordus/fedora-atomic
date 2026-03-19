#!/usr/bin/env bash

# Allows toggling ideapad conservation mode without root

set -euo pipefail

echo "Allowing to toggle ideapad conservation mode without root"

SUDOERS_LINE="ALL ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\\:??/conservation_mode"
SUDOERS_DIR="/etc/sudoers.d"
SUDOERS_FILENAME="010-ideapad-conservation_mode"
SUDOERS_FILE="${SUDOERS_DIR}/${SUDOERS_FILENAME}"

mkdir -p ${SUDOERS_DIR}
echo ${SUDOERS_LINE} > ${SUDOERS_FILE}
chmod 0440 ${SUDOERS_FILE}
