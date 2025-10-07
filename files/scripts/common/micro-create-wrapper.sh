#!/usr/bin/env bash

# Installs a wrapper for 'micro' that always uses '--colorscheme=simple',
# which works great with both light and dark themes.

set -euo pipefail

MICRO_WRAPPER="/usr/bin/micro"
MICRO_RENAMED="/usr/bin/micro-bin"

echo "Setting up 'micro' wrapper to always use '--colorscheme=simple'"

# Check if renamed micro already exists
if [ -f "$MICRO_RENAMED" ]; then
    echo "- Wrapper already installed. Nothing to do."
    exit 0
fi

# Check if micro is installed
if ! command -v micro &> /dev/null; then
    echo "- The package 'micro' is not installed. Skipping."
    exit 0
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

# Create the wrapper
echo "- Creating wrapper at '$MICRO_WRAPPER'"
cat << EOF > "$MICRO_WRAPPER"
#!/bin/sh
exec $MICRO_RENAMED --colorscheme=simple "\$@"
EOF

# Make the wrapper executable
echo "- Setting executable permissions on wrapper"
chmod +x "$MICRO_WRAPPER"

echo "- Done."
