#!/usr/bin/env bash

# Sets up fish completions for brew if both are installed

set -euo pipefail

if [[ ! -d "/usr/share/homebrew" ]] || ! command -v fish &> /dev/null; then
    echo "Either 'brew' or 'fish' is not installed. Skipping."
    exit 0
fi

echo -e "\e[1m\e[38;5;214mInstalling 'brew' fish completion\e[0m"

FISH_VENDOR_DIR="/usr/share/fish/vendor_conf.d"
mkdir -p "${FISH_VENDOR_DIR}"
cat << 'EOF' > "${FISH_VENDOR_DIR}/brew.fish"
#!/usr/bin/fish
#shellcheck disable=all

if status --is-interactive
    if [ -d /home/linuxbrew/.linuxbrew ]
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        if test -d (brew --prefix)/share/fish/completions
            set -p fish_complete_path (brew --prefix)/share/fish/completions
        end
        if test -d (brew --prefix)/share/fish/vendor_completions.d
            set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
        end
    end
end
EOF
