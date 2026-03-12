#!/usr/bin/env bash

# Installs a wrapper for 'micro' that always uses '--colorscheme=simple',
# which works great with both light and dark themes.

set -euo pipefail

create_micro_wrapper() {
    local MICRO_WRAPPER="/usr/bin/micro"
    local MICRO_RENAMED="/usr/bin/micro-bin"

    echo "Creating 'micro' wrapper to use '--colorscheme=simple' by default..."

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
    sudo mv "$MICRO_WRAPPER" "$MICRO_RENAMED"

    local MICRO_WRAPPER_CONTENT='#!/bin/sh\nexec '"$MICRO_RENAMED"' --colorscheme=simple "$@"'

    # Create the wrapper
    echo "- Creating wrapper at '$MICRO_WRAPPER'"
    # Write it to the wrapper file
    echo -e "$MICRO_WRAPPER_CONTENT" | sudo tee -a "$MICRO_WRAPPER" > /dev/null

    # Ensure wrapper has the right permissions
    sudo chmod 755 "$MICRO_WRAPPER"

    echo "- Wrapper created."
}

setup_micro () {
    echo "Checking if the package 'micro' is installed..."

    # Proceed only if micro is installed
    if ! command -v micro &> /dev/null; then
        echo "- Error: Package not installed."
        exit 1
    else
        echo "- Package installed. Proceeding..."
    fi

    create_micro_wrapper
}

setup_micro
