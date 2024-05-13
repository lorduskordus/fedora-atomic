# Allow Flatpak apps to access theming related directories
fix-flatpak-theming ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    override_flatpak_perms () {
        if [ "$1" == "--system" ]; then
            PRIV_PREFIX="pkexec "
        fi

        ${PRIV_PREFIX}flatpak "$1" override \
        --filesystem="xdg-config/gtk-3.0:ro" \
        --filesystem="xdg-config/gtk-4.0:ro" \
        --filesystem="xdg-data/icons:ro" \
        --filesystem="xdg-data/themes:ro"
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "system & user" "only system" "only user")
    fi
    
    if [ "${OPTION}" == "system & user" ]; then
        override_flatpak_perms --user
        override_flatpak_perms --system
    elif [ "${OPTION}" == "only system" ]; then
        override_flatpak_perms --system
    elif [ "${OPTION}" == "only user" ]; then
        override_flatpak_perms --user
    elif [ -n "${OPTION}" ]; then
        echo "The input '${OPTION}' is invalid."
        exit 0
    else
        echo "No changes applied."
        exit 0
    fi