# Switch to another image
switch-to-image ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    show_info () {
        echo "  ● ${bold}From${normal}:     ${OWNER}"
        echo "  ● ${bold}Image${normal}:    ${IMAGE}"
        echo "  ● ${bold}Tag${normal}:      ${TAG}"
        echo "  ● ${bold}Signed${normal}:   ${SIGNED}"
    }

    switch_to () {
        clear
        echo -e "\n${bold}Switching to another image..${normal}"

        IMAGE="$1"

        echo -e "\nChosen image:"
        show_info

        echo
        if ! ugum confirm; then
            echo -e "\nNo changes applied."
            exit 0
        fi

        if [ "${SIGNED}" == "no" ]; then
            PREFIX="${PREFIX_UNSIGNED}"
        else
            PREFIX="${PREFIX_SIGNED}"
        fi

        if [ "${CUR_IMAGE}" == "${PREFIX}/${OWNER}/${IMAGE}:${TAG}" ]; then
            echo -e "\nAlready on the same image."
            exit 0
        else
            echo
            if rpm-ostree rebase ${PREFIX}/${OWNER}/${IMAGE}:${TAG}; then
                echo -e "\nDone. Please reboot."
                notify-send --app-name "Image Switcher" \
                            -i software-update-available-symbolic \
                            "Image switched successfully" \
                            "Please reboot to finish the process."
                exit 0
            else
                echo -e "\nThere was an error while switching to the new image."
                notify-send --app-name "Image Switcher" \
                            -i software-update-available-symbolic \
                            "Image switch failed" \
                            "There was an error while switching to the new image."
                exit 1
            fi
        fi
    }

    something_else () {
        echo -e "\n- ${lightblue}Note${normal}: If the values are empty, current values are taken.\n"
        while [[ -z "${NEW_OWNER}" || -z "${NEW_IMAGE}" || -z "${NEW_TAG}" || -z "${NEW_SIGNED}" ]]; do
            echo "[Current: ${OWNER}]"
            read -p "  ● ${bold}From${normal}: " NEW_OWNER
            echo "[Current: ${IMAGE}]"
            read -p "  ● ${bold}Image${normal}: " NEW_IMAGE
            echo "[Current: ${TAG}]"
            read -p "  ● ${bold}Tag${normal}: " NEW_TAG

            while true; do
                echo "[Current: ${SIGNED}]"
                read -p "  ● ${bold}Signed${normal}(yes/no): " NEW_SIGNED

                if [[ "${NEW_SIGNED}" == "yes" || "${NEW_SIGNED}" == "no" ]]; then
                    SIGNED=${NEW_SIGNED}
                    break
                elif [ "${NEW_SIGNED}" == "" ]; then
                    NEW_SIGNED=${SIGNED}
                    break
                else
                    echo -e "\nType yes/no or leave it empty.\n"
                fi
            done

            if [ -n "${NEW_OWNER}" ]; then
                OWNER=${NEW_OWNER}
            else
                NEW_OWNER=${OWNER}
            fi

            if [ -n "${NEW_IMAGE}" ]; then
                IMAGE=${NEW_IMAGE}
            else
                NEW_IMAGE=${IMAGE}
            fi

            if [ -n "${NEW_TAG}" ]; then
                TAG=${NEW_TAG}
            else
                NEW_TAG=${TAG}
            fi
        done

        switch_to ${IMAGE}
    }

    AVAILABLE_DESKTOPS="gnome \
                        kde"

    CUR_IMAGE=$(rpm-ostree status 2> /dev/null | grep '●' | cut -d' ' -f2)

    PREFIX_SIGNED="ostree-image-signed:docker://ghcr.io"
    PREFIX_UNSIGNED="ostree-unverified-registry:ghcr.io"

    if grep -qw "${PREFIX_SIGNED}" <<< ${CUR_IMAGE}; then
        PREFIX=${PREFIX_SIGNED}
        SIGNED="yes"
    elif grep -qw "${PREFIX_UNSIGNED}" <<< ${CUR_IMAGE}; then
        PREFIX=${PREFIX_UNSIGNED}
        SIGNED="no"
    else
        echo "Couldn't get the prefix of current image."
        exit 1
    fi

    CUR_IMAGE_NO_PREFIX=$(sed "s|${PREFIX}/||" <<< ${CUR_IMAGE})

    OWNER=$(cut -d'/' -f1 <<< ${CUR_IMAGE_NO_PREFIX})
    IMAGE=$(echo ${CUR_IMAGE_NO_PREFIX} | cut -d'/' -f2 | cut -d':' -f1)
    TAG=$(cut -d':' -f2 <<< ${CUR_IMAGE_NO_PREFIX})

    IMAGE_TYPE=$(cut -d'-' -f1-2 <<< ${IMAGE})
    for desktop in ${AVAILABLE_DESKTOPS}; do
        AVAILABLE_IMAGES+="${IMAGE_TYPE}-${desktop} "
    done

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        clear
        echo -e "\nCurrent image:"
        show_info
        echo -e "\nChoose your new ${bold}IMAGE${normal}.\n"

        MENU_IMAGES=$(sed -E "s/${IMAGE}//;s/[[:space:]]\{2,\}/[[:space:]]/" <<< ${AVAILABLE_IMAGES})

        if [ "${SIGNED}" == "no" ]; then
            OPTION=$(ugum choose "current image, but signed" ${MENU_IMAGES} "..something else")
        else
            OPTION=$(ugum choose ${MENU_IMAGES} "..something else")
        fi
    fi

    if [ "${OPTION}" == "current image, but signed" ]; then
        SIGNED="yes"
        switch_to ${IMAGE}
    elif [ "${OPTION}" == "${IMAGE}" ]; then
        echo "Already on the same image."
        exit 0
    elif [ "${OPTION}" == "..something else" ]; then
        clear
        echo -e "\nCurrent image:"
        show_info
        something_else
    elif [ -n "${OPTION}" ]; then
        for available_image in ${AVAILABLE_IMAGES}; do
            image_found=false
            if [ "${OPTION}" == "${available_image}" ]; then
                image_found=true
                break
            fi
        done

        if ${image_found}; then
            if [ "${SIGNED}" == "no" ]; then
                unset SIGNED
                echo "Use signed version of the image ?"
                while [ "${SIGNED}" != "yes" ] && [ "${SIGNED}" != "no" ]; do
                    SIGNED=$(ugum choose "yes" "no")
                done
            fi
            switch_to ${OPTION}
        else
            echo "The input: '${OPTION}' is not valid."
            exit 0
        fi
    else
        echo "No changes applied."
        exit 0
    fi

# Control Ideapad Conservation mode
ideapad-conservation-mode ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
    if [ "${VENDOR}" != "LENOVO" ]; then
        echo "This PC is not LENOVO, cannot continue."
        exit 1
    fi

    STATE_FILE=/sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode
    if [ "$(cat ${STATE_FILE})" == "1" ]; then
        CUR_STATE="enabled"
    else
        CUR_STATE="disabled"
    fi

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        echo "Current state: ${CUR_STATE}"
        OPTION=$(ugum choose setup enable disable)
    fi

    if [ "${OPTION}" == "setup" ]; then
        echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode" > /tmp/ideapad
        if pkexec install -o root -g root -m 0440 /tmp/ideapad /etc/sudoers.d/ideapad; then
            echo "Conservation mode successfuly set up."
            exit 0
        else
            echo "Failed to setup ideapad conservation mode."
            exit 1
        fi
    elif [ "${OPTION}" == "enable" ]; then
        if [ "${CUR_STATE}" == "enabled" ]; then
            echo "Already enabled."
            exit 0
        else
            if echo 1 | sudo tee ${STATE_FILE} &> /dev/null; then
                echo "Successfuly enabled."
            else
                echo "Failed to enable."
            fi
        fi
    elif [ "${OPTION}" == "disable" ]; then
        if [ "${CUR_STATE}" == "disabled" ]; then
            echo "Already disabled."
            exit 0
        else
            if echo 0 | sudo tee ${STATE_FILE} &> /dev/null; then
                echo "Successfuly disabled."
            else
                echo "Failed to disable."
            fi
        fi
    else
        echo "No changes applied."
    fi
