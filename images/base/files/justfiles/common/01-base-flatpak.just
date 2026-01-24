# Flatpak stuff
flatpak ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    override_permissions () {
        flatpak_override () {
            if [ "$1" == "--system" ]; then
                PRIV_PREFIX="/usr/bin/pkexec "
            fi

            if [ -z "$2" ]; then
                echo "No permissions to override specified."
                exit 1
            fi

            ${PRIV_PREFIX}/usr/bin/flatpak override "$@"
        }

        PERMS="$1"

        OPTION={{ ACTION }}
        if [ "${OPTION}" == "prompt" ]; then
            OPTION=$(ugum choose "system & user" "only system" "only user")
        fi

        if [ "${OPTION}" == "system & user" ]; then
            flatpak_override --user ${PERMS[@]}
            flatpak_override --system ${PERMS[@]}
        elif [ "${OPTION}" == "only system" ]; then
            flatpak_override --system ${PERMS[@]}
        elif [ "${OPTION}" == "only user" ]; then
            flatpak_override --user ${PERMS[@]}
        elif [ -n "${OPTION}" ]; then
            echo "The input '${OPTION}' is invalid."
            exit 0
        else
            echo "No changes applied."
            exit 0
        fi
    }

    fix-theming () {
        PERMS="--filesystem=xdg-config/gtk-3.0:ro \
               --filesystem=xdg-config/gtk-4.0:ro \
               --filesystem=xdg-data/icons:ro \
               --filesystem=xdg-data/themes:ro"
        override_permissions "${PERMS}"
    }

    enable-wayland-socket () {
        PERMS="--socket=wayland"
        override_permissions "${PERMS}"
    }

    install-codecs () {
        DEFAULT_BROWSER="$(xdg-settings get default-web-browser 2> /dev/null | sed 's/\.desktop$//')"
        RUNTIME_VERSION="$(flatpak info --show-runtime ${DEFAULT_BROWSER} 2> /dev/null | awk -F/ '{print $NF}')"
        if [ -z "${RUNTIME_VERSION}" ]; then
            echo "Codec runtimes are determined from the default browser. Either it isn't set or the browser is not packaged in Flatpak."
            exit 0
        fi
        CODECS_STR="org.freedesktop.Platform.ffmpeg-full/x86_64/${RUNTIME_VERSION} org.freedesktop.Platform.VAAPI.Intel/x86_64/${RUNTIME_VERSION}"
        flatpak install --system ${CODECS_STR}
    }

    install-mangohud () {
        RUNTIME_VERSION="$(flatpak info --show-runtime com.valvesoftware.Steam 2> /dev/null | awk -F/ '{print $NF}')"
        INSTALLATION_TYPE="--$(LANG=en_US.UTF-8 flatpak info com.valvesoftware.Steam | grep Installation: | cut -d" " -f2)"
        if [ -z "${RUNTIME_VERSION}" ]; then
            echo "MangoHud's runtime is determined from the Steam Flatpak, which is not installed."
            exit 0
        fi
        flatpak ${INSTALLATION_TYPE} install org.freedesktop.Platform.VulkanLayer.MangoHud//${RUNTIME_VERSION}
    }

    brave-plasma-integration () {
        SRC_APP_ID="io.github.ungoogled_software.ungoogled_chromium"
        DST_APP_ID="com.brave.Browser"

        FLATPAK_DIR="${HOME}/.var/app"

        JSON_NAME="org.kde.plasma.browser_integration.json"
        BIN_NAME="plasma-browser-integration-host"

        SRC_JSON="${FLATPAK_DIR}/${SRC_APP_ID}/config/chromium/NativeMessagingHosts/${JSON_NAME}"
        SRC_HOST="${FLATPAK_DIR}/${SRC_APP_ID}/${BIN_NAME}"

        DST_JSON="${FLATPAK_DIR}/${DST_APP_ID}/config/BraveSoftware/Brave-Browser/NativeMessagingHosts/${JSON_NAME}"
        DST_HOST="${FLATPAK_DIR}/${DST_APP_ID}/${BIN_NAME}"

        # Check that destination app  is installed
        if ! flatpak info ${DST_APP_ID} &>/dev/null; then
            echo "App '${DST_APP_ID}' is not installed."
            exit 1
        fi

        # Check that both source files exist
        if [[ ! -f "${SRC_JSON}" || ! -f "${SRC_HOST}" ]]; then
            echo "One or more source files are missing. Do you have 'plasma-browser-integration' installed ?"
            exit 1
        fi

        # Ensure destination exists
        mkdir -p "$(dirname "${DST_JSON}")"
        mkdir -p "$(dirname "${DST_HOST}")"

        # Copy stuff
        cp -f "${SRC_JSON}" "${DST_JSON}"
        cp -f "${SRC_HOST}" "${DST_HOST}"

        # Replace source ID with destination ID in destination JSON
        sed -i "s|${SRC_APP_ID}|${DST_APP_ID}|g" "${DST_JSON}"

        # Set up Flatpak permission
        flatpak override --user --talk-name=org.kde.plasma.browser.integration ${DST_APP_ID}

        echo "Done. KDE Plasma browser integration set up for '${DST_APP_ID}'."
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "fix-theming" "enable-wayland-socket" "install-codecs" "install-mangohud" "brave-plasma-integration")
    fi

    if [ "${OPTION}" == "fix-theming" ]; then
        fix-theming
    elif [ "${OPTION}" == "enable-wayland-socket" ]; then
        enable-wayland-socket
    elif [ "${OPTION}" == "install-codecs" ]; then
        install-codecs
    elif [ "${OPTION}" == "install-mangohud" ]; then
        install-mangohud
    elif [ "${OPTION}" == "brave-plasma-integration" ]; then
        brave-plasma-integration
    else
        echo "No changes applied."
        exit 0
    fi
