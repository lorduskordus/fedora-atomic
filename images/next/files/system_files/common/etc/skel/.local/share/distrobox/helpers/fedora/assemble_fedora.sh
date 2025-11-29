#!/usr/bin/env bash

# Fully assembles Fedora

run_scripts () {
    RUN_SCRIPT_FILE="./run_scripts.sh"

    echo "- Running setup scripts"

    if [ ! -f ${RUN_SCRIPT_FILE} ]; then
        echo "  - Error: File '${RUN_SCRIPT_FILE}' is missing."
        exit 1
    fi

    bash ${RUN_SCRIPT_FILE}
}

assemble_manually () {
    IMAGE="ghcr.io/ublue-os/fedora-toolbox:latest"
    PACKAGES="micro"
    PRE_INIT_HOOKS="export SHELL=/bin/fish"
    INIT_HOOKS="cp -f ${DISTROBOX_HOST_HOME:-$HOME}/.local/share/distrobox/helpers/common/fish_prompt.fish /etc/fish/functions/fish_prompt.fish"
    VOLUME1="/usr/share/fish/vendor_functions.d/fish_greeting.fish:/usr/share/fish/vendor_functions.d/fish_greeting.fish:ro"
    VOLUME2="/usr/share/fish/vendor_conf.d/modern-unix-aliases.fish:/usr/share/fish/vendor_conf.d/modern-unix-aliases.fish:ro"
    VOLUME3="/mnt:/mnt"

    echo "- Assembling manually"

    distrobox-rm -f "${CONTAINER_NAME}"

    distrobox-create \
    --name "${CONTAINER_NAME}" \
    --image "${IMAGE}" \
    --nvidia \
    --no-entry \
    --pre-init-hooks "${PRE_INIT_HOOKS}" \
    --init-hooks "${INIT_HOOKS}" \
    --volume "${VOLUME1}" \
    --volume "${VOLUME2}" \
    --volume "${VOLUME3}"

    distrobox-enter -n "${CONTAINER_NAME}"
}

assemble_from_ini () {
    INI_FILE="/etc/distrobox/distrobox.ini"

    echo "- Assembling from INI file"

    if [ ! -f "${INI_FILE}" ]; then
        echo "  - Error: INI file '${INI_FILE}' is missing."
        exit 1
    fi

    distrobox-assemble create --replace --file ${INI_FILE} --name ${CONTAINER_NAME}
}

assemble_fedora () {
    source environment

    echo "Fully assembling Fedora"

    assemble_from_ini
    run_scripts
}

assemble_fedora
