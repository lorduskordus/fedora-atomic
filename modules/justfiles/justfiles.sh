#!/usr/bin/env bash

set -euo pipefail

get_json_array CONFIG_SELECTION 'try .["include"][]' "$1"
VALIDATE="$(echo "$1" | jq -r 'try .["validate"]')"
USING_UJUST="$(echo "$1" | jq -r 'try .["using-ujust"]')"

MODULE_FOLDER="${MODULE_DIRECTORY}/justfiles"
CONFIG_FOLDER="${CONFIG_DIRECTORY}/justfiles"
DEST_FOLDER="/usr/share/bluebuild/justfiles"

# Abort if justfiles folder is not present
if [ ! -d "${CONFIG_FOLDER}" ]; then
    echo "Error: The config folder '${CONFIG_FOLDER}' was not found."
    exit 1
fi

# If USING_UJUST is specified, validate it
# else 
# Determine ujust usage from the presence of justfile and import line
if [ "${USING_UJUST}" != "null" ]; then
    if [[ "${USING_UJUST}" != "true" && "${USING_UJUST}" != "false" ]]; then
        echo "Error: The value of key 'using-ujust': '${USING_UJUST}' is not valid. It needs to be true or false."
        exit 1
    fi
else
    IMPORT_FILE_UBLUE="/usr/share/ublue-os/justfile"
    IMPORT_LINE_UBLUE="import? \"/usr/share/ublue-os/just/60-custom.just\""

    if grep -q "${IMPORT_LINE_UBLUE}" "${IMPORT_FILE_UBLUE}" 2> /dev/null; then
        USING_UJUST="true"
    else
        USING_UJUST="false"
    fi
fi

# Install just if not present
echo "Checking if package 'just' is installed"
if ! rpm -q just &> /dev/null; then
    echo "- Package is not installed, installing..."
    dnf5 install -y just
else
    echo "- Package is installed."
fi

# Import to 'justfile' in the bluebuild folder & create the 'bjust' command
# OR
# Import to uBlue's '60-custom.just' (for usage with their 'ujust' command)
if [ "${USING_UJUST}" == "false" ]; then
    IMPORT_FILE="${DEST_FOLDER}/justfile"

    mkdir -p "${DEST_FOLDER}"
    
    if [ ! -f "${IMPORT_FILE}" ]; then
        cp "${MODULE_FOLDER}/justfile" "${IMPORT_FILE}"
    fi

    if [ ! -f "/usr/bin/bjust" ]; then
        install -o root -g root -m 755 "${MODULE_FOLDER}/bjust" /usr/bin/bjust
    fi
else
    IMPORT_FILE="/usr/share/ublue-os/just/60-custom.just"
    
    if [ ! -f "${IMPORT_FILE}" ]; then
        mkdir -p "$(dirname "${IMPORT_FILE}")"
        touch "${IMPORT_FILE}"
    fi
fi
echo "Import lines will be written to: '${IMPORT_FILE}'"

# Include all files in the folder if none specified
if [[ ${#CONFIG_SELECTION[@]} == 0 ]]; then
    CONFIG_SELECTION=($(find "${CONFIG_FOLDER}" -mindepth 1 -maxdepth 1 -exec basename {} \;))
fi

for SELECTED in "${CONFIG_SELECTION[@]}"; do

    echo "------------------------------------------------------------------------"
    echo "--- Adding folder/file '${SELECTED}'"
    echo "------------------------------------------------------------------------"

    # Find all justfiles, starting from 'SELECTED' and get their paths
    JUSTFILES=($(find "${CONFIG_FOLDER}/${SELECTED}" -type f -name "*.just" | sed "s|${CONFIG_FOLDER}/||g"))

    # Abort if no justfiles found at 'SELECTED'
    if [[ ${#JUSTFILES[@]} == 0 ]]; then
        echo "Error: No justfiles were found in '${CONFIG_FOLDER}/${SELECTED}'."
        exit 1
    fi

    # Validate all found justfiles if set to do so
    if [ "${VALIDATE}" == "true" ]; then

        echo "Validating justfiles"
        VALIDATION_FAILED=0
        for JUSTFILE in "${JUSTFILES[@]}"; do
            if ! /usr/bin/just --fmt --check --unstable --justfile "${CONFIG_FOLDER}/${JUSTFILE}" &> /dev/null; then
                echo "- The justfile '${JUSTFILE}' FAILED validation."
                VALIDATION_FAILED=1
            fi
        done

        # Exit if any justfiles are not valid
        if [ ${VALIDATION_FAILED} -eq 1 ]; then
            echo "Error: Some justfiles didn't pass validation."
            exit 1
        else
            echo "- All justfiles passed validation."
        fi

    fi

    # Copy 'SELECTED' to destination folder
    echo "Copying folders/files"
    mkdir -p "${DEST_FOLDER}/$(dirname ${SELECTED})"
    cp -rfT "${CONFIG_FOLDER}/${SELECTED}" "${DEST_FOLDER}/${SELECTED}"
    echo "- Copied '${CONFIG_FOLDER}/${SELECTED}' to '${DEST_FOLDER}/${SELECTED}'."

    # Generate import lines for all found justfiles
    echo "Adding import lines"
    for JUSTFILE in "${JUSTFILES[@]}"; do

        # Create an import line
        IMPORT_LINE="import \"${DEST_FOLDER}/${JUSTFILE}\""
        
        # Skip the import line if it already exists, else append it to import file
        if grep -wq "${IMPORT_LINE}" "${IMPORT_FILE}"; then
            echo "- Skipped: '${IMPORT_LINE}' (already present)"
        else
            echo "${IMPORT_LINE}" >> "${IMPORT_FILE}"
            echo "- Added: '${IMPORT_LINE}'"
        fi

    done

done
