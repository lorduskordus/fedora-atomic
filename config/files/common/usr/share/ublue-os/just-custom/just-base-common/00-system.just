# Switch to another image
switch-to-image ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    AVAILABLE_DESKTOPS="gnome \
                        kde"

    CUR_IMAGE=$(rpm-ostree status 2> /dev/null | grep '●' | cut -d' ' -f2)

    OWNER=$(cut -d'/' -f4 <<< ${CUR_IMAGE})
    IMAGE=$(echo ${CUR_IMAGE} | cut -d'/' -f5 | cut -d':' -f1)
    TAG=$(cut -d':' -f4 <<< ${CUR_IMAGE})

    IMAGE_TYPE=$(cut -d'-' -f1-2 <<< ${IMAGE})

    for desktop in ${AVAILABLE_DESKTOPS}; do
        AVAILABLE_IMAGES+="${IMAGE_TYPE}-${desktop} "
    done

    PREFIX=$(cut -d'/' -f1-3 <<< ${CUR_IMAGE})
    PREFIX_SIGNED="ostree-image-signed:docker://ghcr.io"
    PREFIX_UNSIGNED="ostree-unverified-registry:ghcr.io"

    if [ "${PREFIX}" == "${PREFIX_SIGNED}" ]; then
        SIGNED="yes"
    else
        SIGNED="no"
    fi

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

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        clear
        echo -e "\nCurrent image:"
        show_info
        echo -e "\nChoose your new ${bold}IMAGE${normal}.\n"

        MENU_IMAGES=$(sed -E "s/${IMAGE}//;s/[[:space:]]\{2,\}/[[:space:]]/" <<< ${AVAILABLE_IMAGES})
        OPTION=$(ugum choose ${MENU_IMAGES} "..something else")
    fi

    if [ "${OPTION}" == "${IMAGE}" ]; then
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
            switch_to ${OPTION}
        else
            echo "The input: '${OPTION}' is not valid."
            exit 0
        fi
    else
        echo "No changes applied."
        exit 0
    fi