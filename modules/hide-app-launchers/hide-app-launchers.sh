#!/usr/bin/env bash

set -euo pipefail

get_json_array APPS_TO_HIDE 'try .["hide"][]' "$1"

if [[ ${#APPS_TO_HIDE[@]} == 0 ]]; then
    echo "Error: No apps specified."
    exit 1
fi

APP_LAUNCHERS_LOCATION="/usr/share/applications"

NF_FLAG=0
for APP in "${APPS_TO_HIDE[@]}"; do
    if [ ! -f "${APP_LAUNCHERS_LOCATION}/${APP}.desktop" ]; then
        echo "- App launcher for '${APP}' not found."
        NF_FLAG=1
    fi
done

if [ ${NF_FLAG} -eq 1 ]; then
    echo "Error: Some app launchers could not be found."
    exit 1
else
    echo "All app launchers found."
fi

for APP in "${APPS_TO_HIDE[@]}"; do
    if sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' ${APP_LAUNCHERS_LOCATION}/${APP}.desktop; then
        echo "- Successfully hidden '${APP}.desktop'."
    else
        echo "Error: Failed to hide '${APP}.desktop'."
        exit 1
    fi
done

echo "All app launchers hidden successfully."
