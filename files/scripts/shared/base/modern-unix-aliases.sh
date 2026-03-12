#!/usr/bin/env bash

# Sets up aliases for modern UNIX utility alternatives

set -euo pipefail

########################################
# BASH
########################################

echo -e "\e[1m\e[38;5;214mSetting up modern-unix for bash\e[0m"

# Make sure directory exists
BASH_PROFILE_DIR="/etc/profile.d"
mkdir -p "${BASH_PROFILE_DIR}"

# Set it up
cat << 'EOF' > "${BASH_PROFILE_DIR}/modern-unix-aliases.sh"
# Aliases for modernized versions of common Linux tools

# bat for cat
if command -v bat &> /dev/null; then
    alias cat='bat --theme=ansi --style=plain --pager=never'
fi

# eza for ls & tree
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -lHbg --group-directories-first'
    alias la='eza -lHbgaa --group-directories-first'
    alias tree='eza --tree'
fi
EOF

########################################
# FISH
########################################

# Continue setup only if fish is installed
if ! command -v fish &> /dev/null; then
    echo "Package 'fish' is not installed. Skipping the setup of modern-unix."
    exit 0
fi

echo -e "\e[1m\e[38;5;214mSetting up modern-unix for fish\e[0m"

# Make sure directory exists
FISH_VENDOR_CONF="/usr/share/fish/vendor_conf.d"
mkdir -p "${FISH_VENDOR_CONF}"

# Set it up
cat << 'EOF' > "${FISH_VENDOR_CONF}/modern-unix-aliases.fish"
# Aliases for modernized versions of common Linux tools

# bat for cat
if type -q bat
    alias cat='bat --theme=ansi --style=plain --pager=never'
end

# eza for ls & tree
if type -q eza
    alias ls='eza'
    alias ll='eza -lHbg --group-directories-first'
    alias la='eza -lHbgaa --group-directories-first'
    alias tree='eza --tree'
end
EOF
