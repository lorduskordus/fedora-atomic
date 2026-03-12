#!/usr/bin/env bash

# Customizes Brave's wrapper to include flags from '$HOME/.config/brave-flags.conf'

set -euo pipefail

BRAVE_WRAPPER="/usr/lib/opt/brave.com/brave/brave-browser"

BRAVE_FLAGS_FILE='$HOME/.config/brave-flags.conf'
OPTIONS='$([ -f "'"$BRAVE_FLAGS_FILE"'" ] \&\& cat "'"$BRAVE_FLAGS_FILE"'" | sed '"'s/#.*//'"')'

ORIGINAL_STR='"$HERE/brave" "$@" || true'
NEW_STR='"$HERE/brave" "$@" "'$OPTIONS'" || true'

echo "Adding support for flags file inclusion to the RPM version of Brave browser"

if ! command -v brave-browser &> /dev/null; then
    echo "- Brave is not installed as an RPM package. Flatpak version supports flags out of the box. Skipping."
    exit 0
fi

if [ -f "$BRAVE_WRAPPER" ]; then
    echo "- Found the wrapper '$BRAVE_WRAPPER'."
else
    echo "- Error: Could not find the wrapper '$BRAVE_WRAPPER'."
    echo "    - Someone upstream f'd up and changed how Brave is installed."
    exit 1
fi

if grep -qF "$ORIGINAL_STR" "$BRAVE_WRAPPER"; then
    echo "- Found correct string in the wrapper. Replacing..."
    sed -i "s:$ORIGINAL_STR:$NEW_STR:" "$BRAVE_WRAPPER"; then
elif grep -qF "$NEW_STR" "$BRAVE_WRAPPER"; then
    echo "- The wrapper already contains the correct string. Skipping."
    exit 0
else
    echo "- Error: Could not find string '$ORIGINAL_STR' in the wrapper."
    echo "    - Someone upstream probably f'd up and changed the string."
    exit 1
fi

echo "- Done."
