#!/usr/bin/env bash

# Patches bootc to not need sudo for users in the wheel group
# Adds shell functions for bash and fish

set -euo pipefail

# Bash
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

# Fish
mkdir -p /etc/fish/conf.d
cat << 'EOF' > /etc/fish/conf.d/bootc.fish
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

# Sudoers rule
cat << 'EOF' > /etc/sudoers.d/001-bootc
%wheel ALL=(ALL) NOPASSWD: /usr/bin/bootc update, /usr/bin/bootc update --apply, /usr/bin/bootc upgrade, /usr/bin/bootc upgrade --apply, /usr/bin/bootc status, /usr/bin/bootc status --booted
EOF
