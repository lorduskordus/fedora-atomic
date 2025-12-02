#!/usr/bin/env bash

# Runs scripts inside SCRIPTS_DIR folder, for convenience

SCRIPTS_DIR="./container_scripts"

source environment

if [ ! -d "${SCRIPTS_DIR}" ]; then
    echo "  - Error: Scripts dir '${SCRIPTS_DIR}' is missing."
    exit 1
fi

for script in ${SCRIPTS_DIR}/*; do
    if [ -f "$script" ]; then
        distrobox-enter -n ${CONTAINER_NAME} -- bash "$script"
    fi
done
