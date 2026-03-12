# AM stuff
am ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    install-default-packages () {
        PACKAGE_FILE="/etc/am/default-packages"

        if [ ! -s "${PACKAGE_FILE}" ]; then
            echo "Error: Missing or empty '${PACKAGE_FILE}'. Cannot proceed."
            exit 1
        fi

        PACKAGES=$(cat "${PACKAGE_FILE}")
        /usr/bin/pkexec am -i ${PACKAGES}
    }

    if ! command -v am &> /dev/null; then
        echo "AM package manager is not installed. Cannot proceed."
        exit 1
    fi

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "install-default-packages" "cancel")
    fi

    if [ "${OPTION}" == "install-default-packages" ]; then
        install-default-packages
    else
        echo "No changes applied."
        exit 0
    fi
