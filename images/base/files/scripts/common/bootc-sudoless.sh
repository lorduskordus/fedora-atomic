#!/usr/bin/env bash

# Patches bootc to not need sudo for users in the wheel group
# Adds shell functions for bash and fish

set -euo pipefail

echo "Setting up bootc to work without sudo"

# Sudoers rule
if [ ! -f /etc/sudoers.d/001-bootc ]; then
    cat << 'EOF' > /etc/sudoers.d/001-bootc
%wheel ALL=(ALL) NOPASSWD: /usr/bin/bootc update, /usr/bin/bootc update --apply, /usr/bin/bootc upgrade, /usr/bin/bootc upgrade --apply, /usr/bin/bootc status, /usr/bin/bootc status --booted
EOF

    echo "- Created sudoers rule."
else
    echo "- Sudoers rule already exists. Skipping."
fi

# Bash
if [ ! -f /etc/profile.d/bootc.sh ]; then
    cat << 'EOF' > /etc/profile.d/bootc.sh
if [ "$EUID" -ne 0 ]; then
    bootc() {
        if [ "$EUID" -eq 0 ]; then
            /usr/bin/bootc "$@"
        else
            sudo /usr/bin/bootc "$@"
        fi
    }
fi
EOF

    echo "- Created bootc function for bash."
else
    echo "- Bootc function for bash already exists. Skipping."
fi

# Fish
if command -v fish &> /dev/null; then
    if [ ! -f /usr/share/fish/vendor_conf.d/bootc.fish ]; then
        cat << 'EOF' > /usr/share/fish/vendor_conf.d/bootc.fish
if test (id -u) -ne 0
    function bootc
        if test (id -u) -eq 0
            /usr/bin/bootc $argv
        else
            sudo /usr/bin/bootc $argv
        end
    end
end
EOF

        echo "- Created bootc function for fish."
    else
        echo "- Bootc function for fish already exists. Skipping."
    fi
fi

echo "- Done."
