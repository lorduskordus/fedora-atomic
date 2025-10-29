#!/usr/bin/env bash

# - Installs a wrapper for 'micro' that always uses '--colorscheme=simple',
#   which works great with both light and dark themes.
#
# - Replaces 'nano' in default-editor configs with 'micro' to set it as the default.

set -euo pipefail

create_micro_wrapper() {
    local MICRO_WRAPPER="/usr/bin/micro"
    local MICRO_RENAMED="/usr/bin/micro-bin"

    # Check if renamed micro already exists
    if [ -f "$MICRO_RENAMED" ]; then
        echo "- Wrapper already installed. Skipping."
        return
    fi

    # Make sure micro binary is at the expected place
    if [ ! -f "$MICRO_WRAPPER" ]; then
        echo "- Error: Could not find micro binary at '$MICRO_WRAPPER'"
        exit 1
    fi

    echo "- Found micro binary at '$MICRO_WRAPPER'"

    # Rename the original binary
    echo "- Renaming '$MICRO_WRAPPER' to '$MICRO_RENAMED'"
    mv "$MICRO_WRAPPER" "$MICRO_RENAMED"

    local MICRO_WRAPPER_CONTENT='#!/bin/sh\nexec '"$MICRO_RENAMED"' --colorscheme=simple "$@"'

    # Create the wrapper
    echo "- Creating wrapper at '$MICRO_WRAPPER'"
    # Write it to the wrapper file
    echo -e "$MICRO_WRAPPER_CONTENT" > "$MICRO_WRAPPER"

    # Ensure wrapper has the right permissions
    chmod 755 "$MICRO_WRAPPER"
    
    echo "- Wrapper created."
}

replace_nano_with_micro() {
    local FILE_ORIG="$1"
    local FILE_NEW="${FILE_ORIG/nano-default-editor/micro-default-editor}"

    echo "- Updating '$FILE_ORIG'..."

    # Check if the file exists
    if [[ -f "$FILE_ORIG" ]]; then
        # Rename it
        mv "$FILE_ORIG" "$FILE_NEW"

        # Update its contents
        sed -i 's|/usr/bin/nano|/usr/bin/micro|g' "$FILE_NEW"
        sed -i 's|GNU nano|MIT micro|' "$FILE_NEW"
        
        echo "  - Updated."
    # Does not exist, because it was already processed before
    elif [[ -f "$FILE_NEW" ]]; then
        echo "  - Skipped. (Already updated)"
    # Does not exist, because bad input
    else
        echo "  - Error: Could not find '$FILE_ORIG'."
        exit 1
    fi
}

echo "Checking if the package 'micro' is installed..."

# Proceed only if micro is installed
if command -v micro &> /dev/null; then
    echo "- Package found. Proceeding."
else
    echo "- Package not found. Skipping."
    exit 0
fi

echo "Creating 'micro' wrapper to use '--colorscheme=simple' by default..."

create_micro_wrapper

echo "Replacing nano configs to use micro instead..."

# Replace configs in /etc/profile.d
replace_nano_with_micro "/etc/profile.d/nano-default-editor.sh"
replace_nano_with_micro "/etc/profile.d/nano-default-editor.csh"

# Replace configs in /usr/share/fish if fish is installed
if command -v fish &> /dev/null; then
    replace_nano_with_micro "/usr/share/fish/vendor_conf.d/nano-default-editor.fish"
fi

echo "Done."
