#!/usr/bin/env bash

# Disables CPU Boost feature on Tuned's balanced profiles by default

set -euo pipefail

echo "Disabling CPU Boost feature on Tuned's balanced profiles"

# For COSMIC images, the package is installed only after this script, failing it.
# Install it here early, so I can keep my "clean" config
if ! command -v tuned &> /dev/null; then
    echo "  - Warning: Package 'tuned' is not installed, installing.."
    dnf5 install -y tuned
fi

PROFILES=(
    balanced
    balanced-battery
)

TUNED_PROFILES_DIR="/usr/lib/tuned/profiles"
mkdir -p "${TUNED_PROFILES_DIR}"
for profile in "${PROFILES[@]}"; do

    CONF_FILE="${TUNED_PROFILES_DIR}/${profile}/tuned.conf"

    if [ ! -f "${CONF_FILE}" ]; then
        echo "  - Error: Profile '${profile}' is missing"
        exit 1
    fi

    if grep -q "boost=1" "${CONF_FILE}" 2> /dev/null; then
        echo "  - Modifying '${profile}' profile"
        sed -i 's|boost=1|boost=0|' "${CONF_FILE}"
    elif grep -q "boost=0" "${CONF_FILE}" 2> /dev/null; then
        echo "  - Profile '${profile}' already modified"
    else
        echo "  - Profile '${profile}' does not contain 'boost' config"
        # echo -e "\nProfile '${profile}' does not contain 'boost' config"
        # echo "------------------------------------------------------------------"
        # cat "${CONF_FILE}"
        # echo "------------------------------------------------------------------"
    fi

done
