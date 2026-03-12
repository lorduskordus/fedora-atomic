# Add yourself to groups
groups ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    add_to_group () {
        app="$1"
        group="${APPS[$app]}"

        # Check if the app is installed
        if ! command -v "$app" &> /dev/null || [ -z "$group" ]; then
            echo "App: '${bold}$app${normal}'"
            echo "  - Not a valid option"
            echo "    - Options: ${bold}${APP_OPTIONS}${normal}"
            return 1
        fi

        # Get group line from /usr/lib/group
        lib_group_line=$(grep -E "^${group}:" /usr/lib/group)
        if [ -z "$lib_group_line" ]; then
            echo "App: '${bold}$app${normal}'"
            echo "  - Group '${bold}${group}${normal}' not defined in /usr/lib/group. Cannot proceed."
            return 1
        fi

        # Check if /etc/group has that line
        etc_group_line=$(grep -E "^${group}:" /etc/group | awk -F: '{ $NF=""; print }' OFS=: )
        if [ "$etc_group_line" != "$lib_group_line" ]; then
            # Remove the old line if it exists
            if [ -n "$etc_group_line" ]; then
                sudo sed -i "/^${group}:/d" /etc/group
            fi
            # Add the correct line
            echo "$lib_group_line" | sudo tee -a /etc/group > /dev/null
        fi

        # Add user to group if not already a member
        if id -nG "$USER" | grep -qw "$group"; then
            echo "App: '${bold}$app${normal}'"
            echo "  - User '${bold}${USER}${normal}' is already in group '${bold}${group}${normal}'"
        else
            if sudo usermod -aG "$group" "$USER"; then
                echo "App: '${bold}$app${normal}'"
                echo "  - User '${bold}${USER}${normal}' added to group '${bold}${group}${normal}'"
            else
                echo "App: '${bold}$app${normal}'"
                echo "  - Failed adding to group '${bold}${group}${normal}'"
            fi
        fi
    }

    # Associative Array - ["APP"]="APP_GROUP"
    declare -A APPS
    APPS["wireshark"]="wireshark"
    APPS["virt-manager"]="libvirt"
    APPS["docker"]="docker"
    APPS["virtualbox"]="vboxusers"

    for app in "${!APPS[@]}"; do
        if command -v $app &> /dev/null; then
            APP_OPTIONS+="${app} "
        fi
    done

    if [ -z "${APP_OPTIONS}" ]; then
        echo "No application this script knows about is installed."
        exit 1
    fi

    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
        OPTION=$(ugum choose "all" ${APP_OPTIONS})
    fi

    if [ "$OPTION" == "all" ]; then
        for app in ${APP_OPTIONS}; do
            add_to_group "$app"
        done
    elif [ -n "${OPTION}" ]; then
        add_to_group "${OPTION}"
    else
        echo "No changes applied."
        exit 0
    fi
