#!/usr/bin/env bash

# Makes fish shell more ready
#  - disables useless greeting
#  - makes it container aware

set -euo pipefail

# Setup only if fish is installed
if ! command -v fish &> /dev/null; then
    echo "Package 'fish' is not installed. Skipping."
    exit 0
fi

# Make sure directory exists
FISH_VENDOR_FUNCTIONS="/usr/share/fish/vendor_functions.d"
mkdir -p "${FISH_VENDOR_FUNCTIONS}"

# Disable useless fish greeting
echo "Disabling useless fish greeting"

cat << 'EOF' > "${FISH_VENDOR_FUNCTIONS}/fish_greeting.fish"
#!/usr/bin/fish
#shellcheck disable=all

function fish_greeting
    if set -q fish_private_mode
        echo "fish is running in private mode, history will not be persisted."
    end
end
EOF

# Make fish container aware
echo "Making fish container aware"

cat << 'EOF' > "${FISH_VENDOR_FUNCTIONS}/fish_prompt.fish"
function fish_prompt --description 'Default prompt with container detection'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red
    set -g fish_color_user brgreen

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Detect if we are in a container
    if test -n "$CONTAINER_ID"
        set -g prompt_host "[$CONTAINER_ID]"
        set -g prefix_icon "📦 "
    else
    	set -g prompt_host "$hostname"
    	set -g prefix_icon ""
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s $prefix_icon (set_color $fish_color_user) "$USER" $normal "@" $prompt_host' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
end
EOF
