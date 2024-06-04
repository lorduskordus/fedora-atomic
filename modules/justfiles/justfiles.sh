#!/usr/bin/env bash

set -euo pipefail

get_yaml_array JUSTFILES_SELECTED '.include[]' "$1"

JUSTFILES_IMPORT_FILE="/usr/share/ublue-os/just/60-custom.just"
JUSTFILES_FOLDER="${CONFIG_DIRECTORY}/justfiles"
BLUEBUILD_FOLDER="/usr/share/bluebuild/justfiles"

echo "Installing justfiles module"

# Abort if justfiles folder is not present
if [ ! -d "${JUSTFILES_FOLDER}" ]; then
    echo "Module failed because the folder '${JUSTFILES_FOLDER}' was not found."
    exit 1
fi

# Include all files in the folder if none specified
if [[ ${#JUSTFILES_SELECTED[@]} == 0 ]]; then
    JUSTFILES_SELECTED=($(ls "${JUSTFILES_FOLDER}"))
fi

for selected in "${JUSTFILES_SELECTED[@]}"; do
    JUSTFILES=($(find "${JUSTFILES_FOLDER}/${selected}" -type f -name "*.just" | sed "s|${JUSTFILES_FOLDER}/||g"))
    if [[ ${#JUSTFILES[@]} == 0 ]]; then
        echo "Module failed because no justfiles were found in '${JUSTFILES_FOLDER}/${selected}'"
        exit 1
    else
        mkdir -p "${BLUEBUILD_FOLDER}/$(dirname ${selected})"
        cp -rfT "${JUSTFILES_FOLDER}/${selected}" "${BLUEBUILD_FOLDER}/${selected}"
        echo -e "\nJustfile import lines for folder/file '${selected}' being added:\n"
        for justfile in "${JUSTFILES[@]}"; do
            IMPORT_LINE="import \"${BLUEBUILD_FOLDER}/${justfile}\""
            if grep -wq "${IMPORT_LINE}" "${JUSTFILES_IMPORT_FILE}"; then
                echo "Module failed because of duplicated import line: '${IMPORT_LINE}'"
                exit 1
            else
                echo "${IMPORT_LINE}" | tee -a "${JUSTFILES_IMPORT_FILE}"
            fi
        done
    fi
done