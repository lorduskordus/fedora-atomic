#!/usr/bin/env bash

set -euo pipefail

get_json_array APPS_TO_HIDE 'try .["hide"][]' "$1"

if [[ ${#APPS_TO_HIDE[@]} == 0 ]]; then
    echo "Error: No apps specified."
    exit 1
fi

APP_LAUNCHERS_LOCATION="/usr/share/applications"

for APP in "${APPS_TO_HIDE[@]}"; do
    if [ ! -f "${APP_LAUNCHERS_LOCATION}/${APP}.desktop" ]; then
        echo "- App launcher for '${APP}' not found. Skipping."
        continue
    fi

    APPS_TO_HIDE_FOUND+=("${APP}")
done

for APP in "${APPS_TO_HIDE_FOUND[@]}"; do
    if sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' ${APP_LAUNCHERS_LOCATION}/${APP}.desktop; then
        echo "- Successfully hidden '${APP}.desktop'."
    else
        echo "Error: Failed to hide '${APP}.desktop'."
        exit 1
    fi
done

echo "All found app launchers hidden successfully."
