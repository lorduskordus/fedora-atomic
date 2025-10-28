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
        if [ -z "${RUNTIME_VERSION}" ]; then
            echo "MangoHud's runtime is determined from the Steam Flatpak, which is not installed."
            exit 0
        fi
        flatpak --system install org.freedesktop.Platform.VulkanLayer.MangoHud//${RUNTIME_VERSION}
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "fix-theming" "enable-wayland-socket" "install-codecs" "install-mangohud")
    fi

    if [ "${OPTION}" == "fix-theming" ]; then
        fix-theming
    elif [ "${OPTION}" == "enable-wayland-socket" ]; then
        enable-wayland-socket
    elif [ "${OPTION}" == "install-codecs" ]; then
        install-codecs
    elif [ "${OPTION}" == "install-mangohud" ]; then
        install-mangohud
    else
        echo "No changes applied."
        exit 0
    fi
