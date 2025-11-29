#!/usr/bin/env bash

# Customizes Unity's launcher to use discrete GPU and MangoHUD (for FPS limit)

set -euo pipefail

DESKTOP_FILE="/usr/share/applications/unityhub.desktop"

echo "Make Unity use discrete GPU and MangoHUD"

if ! command -v unityhub &> /dev/null; then
    echo "- Unity is not installed as an RPM package. Skipping."
    exit 0
fi

if [ -f "$DESKTOP_FILE" ]; then
    echo "- Found the launcher '$DESKTOP_FILE'."
else
    echo "- Error: Could not find the launcher '$DESKTOP_FILE'."
    echo "    - Someone upstream f'd up and changed how Unity is installed."
    exit 1
fi

# Use discrete GPU

DGPU_STR="PrefersNonDefaultGPU=true"

echo "- Discrete GPU"

if grep -qF "$DGPU_STR" "$DESKTOP_FILE"; then
    echo "  - Already enabled."
else
    echo "  - Enabling it."
    echo "PrefersNonDefaultGPU=true" >> "$DESKTOP_FILE"
fi

# Use MangoHUD

ORIGINAL_EXEC_STR='Exec=/opt/unityhub/unityhub %U'
NEW_EXEC_STR='Exec=/usr/bin/mangohud /opt/unityhub/unityhub %U'

echo "- MangoHUD"

if ! command -v mangohud &> /dev/null; then
    echo "  - Error: Not installed as an RPM package."
    exit 1
fi

if grep -qF "$ORIGINAL_EXEC_STR" "$DESKTOP_FILE"; then
    echo "  - Found correct Exec string in the launcher."
    echo "  - Enabling it."
    sed -i "s:$ORIGINAL_EXEC_STR:$NEW_EXEC_STR:" "$DESKTOP_FILE"
elif grep -qF "$NEW_EXEC_STR" "$DESKTOP_FILE"; then
    echo "  - Already enabled."
else
    echo "  - Error: Could not find Exec string '$ORIGINAL_EXEC_STR' in the launcher."
    echo "      - Someone upstream probably f'd up and changed the string."
    exit 1
fi

echo "- Done."
