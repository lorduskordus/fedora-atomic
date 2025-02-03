# Switch to another image
switch-to-image WITH="bootc":
    #!/usr/bin/pkexec /usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    show_info () {
        local TITLE="$1"
        local TITLE_ACTION="$2"
        local INFO_SCOPE="$3"

        if [ "${INFO_SCOPE}" == "new" ]; then
            local SHOW_OWNER="${NEW_OWNER}"
            local SHOW_IMAGE="${NEW_IMAGE}"
            local SHOW_TAG="${NEW_TAG}"
            local SHOW_SIGNED="${NEW_SIGNED}"
        else
            local SHOW_OWNER="${OWNER}"
            local SHOW_IMAGE="${IMAGE}"
            local SHOW_TAG="${TAG}"
            local SHOW_SIGNED="${SIGNED}"
        fi

        clear

        if [ -n "${TITLE}" ]; then
            echo -e "${bold}${green}${TITLE}${normal}\n"
        fi

        echo "  ● ${bold}From${normal}:     ${SHOW_OWNER}"
        echo "  ● ${bold}Image${normal}:    ${SHOW_IMAGE}"
        echo "  ● ${bold}Tag${normal}:      ${SHOW_TAG}"
        echo "  ● ${bold}Signed${normal}:   ${SHOW_SIGNED}"

        if [ "${INFO_SCOPE}" == "include_reboot" ]; then
            echo "  ● ${bold}Reboot${normal}:   ${REBOOT}"
        fi

        if [ -n "${TITLE_ACTION}" ]; then
            echo -e "\n${TITLE_ACTION}\n"
        fi
    }

    switch_to () {
        local IMAGE="$1"
        local TITLE="Chosen image:"

        show_info "${TITLE}" "Choose, whether to ${bold}reboot automatically${normal} after a ${bold}successful switch${normal}."
        if ugum confirm "Reboot automatically ?"; then
            REBOOT="yes"
        fi

        show_info "${TITLE}" "Confirm your ${bold}IMAGE choice${normal}." "include_reboot"
        if ! ugum confirm; then
            echo "No changes applied."
            exit 0
        fi

        if [ "${SIGNED}" == "no" ]; then
            PREFIX="${PREFIX_UNSIGNED}"
        else
            PREFIX="${PREFIX_SIGNED}"

            # if bootc
            if [ "${IMAGE_TOOL}" = "bootc" ]; then
                POLICY_ARG="--enforce-container-sigpolicy "
            fi
        fi

        if [ "${REBOOT}" == "yes" ]; then
            # if bootc
            if [ "${IMAGE_TOOL}" = "bootc" ]; then
                REBOOT_ARG="--apply "
            # else rpm-ostree
            else
                REBOOT_ARG="-r "
            fi
        fi

        # if bootc
        if [ "${IMAGE_TOOL}" = "bootc" ]; then
            local REBASE_COMMAND="bootc switch ${REBOOT_ARG}${POLICY_ARG}${SOURCE}/${OWNER}/${IMAGE}:${TAG}"
        # else rpm-ostree
        else
            local REBASE_COMMAND="rpm-ostree rebase ${REBOOT_ARG}${PREFIX}${SOURCE}/${OWNER}/${IMAGE}:${TAG}"
        fi

        # if bootc
        if [ "${IMAGE_TOOL}" = "bootc" ]; then
            if [ "${CUR_IMAGE_NO_PREFIX}" == "${SOURCE}/${OWNER}/${IMAGE}:${TAG}" ]; then
                echo "Already on the same image."
                exit 0
            fi
        # else rpm-ostree
        else
            if [ "${CUR_IMAGE}" == "${PREFIX}${SOURCE}/${OWNER}/${IMAGE}:${TAG}" ]; then
                echo "Already on the same image."
                exit 0
            fi
        fi

        clear
        echo -e "${bold}${green}Switching to new IMAGE${normal}."
        echo -e "${blue}- Running command: '${REBASE_COMMAND}'${normal}\n"

        if ${REBASE_COMMAND}; then
            echo -e "\n${green}- Done. Please reboot.${normal}"
            notify-send --app-name "Image Switcher" \
                        -i software-update-available-symbolic \
                        "Image switched successfully" \
                        "Please reboot to finish the process."
            exit 0
        else
            echo -e "\n${red}- There was an error while switching to the new image.${normal}"
            notify-send --app-name "Image Switcher" \
                        -i software-update-available-symbolic \
                        "Image switch failed" \
                        "There was an error while switching to the new image."
            exit 1
        fi
    }

    something_else () {
        local TITLE="New image values:"
        local TITLE_ACTION="- ${bold}${blue}Note${normal}: If the values are left empty, values from current image are taken."
        local INFO_SCOPE="new"

        show_info "${TITLE}" "${TITLE_ACTION}" "${INFO_SCOPE}"
        echo "[Current image: ${OWNER}]"
        read -p "  ● ${bold}From${normal}: " NEW_OWNER

        if [ -n "${NEW_OWNER}" ]; then
            OWNER=${NEW_OWNER}
        else
            NEW_OWNER=${OWNER}
        fi

        show_info "${TITLE}" "${TITLE_ACTION}" "${INFO_SCOPE}"
        echo "[Current image: ${IMAGE}]"
        read -p "  ● ${bold}Image${normal}: " NEW_IMAGE

        if [ -n "${NEW_IMAGE}" ]; then
            IMAGE=${NEW_IMAGE}
        else
            NEW_IMAGE=${IMAGE}
        fi

        show_info "${TITLE}" "${TITLE_ACTION}" "${INFO_SCOPE}"
        echo "[Current image: ${TAG}]"
        read -p "  ● ${bold}Tag${normal}: " NEW_TAG

        if [ -n "${NEW_TAG}" ]; then
            TAG=${NEW_TAG}
        else
            NEW_TAG=${TAG}
        fi

        while true; do
            show_info "${TITLE}" "${TITLE_ACTION}" "${INFO_SCOPE}"
            echo "[Current image: ${SIGNED}]"
            read -p "  ● ${bold}Signed${normal}(yes/no): " NEW_SIGNED

            if [[ "${NEW_SIGNED}" == "yes" || "${NEW_SIGNED}" == "no" ]]; then
                SIGNED=${NEW_SIGNED}
                break
            elif [ "${NEW_SIGNED}" == "" ]; then
                NEW_SIGNED=${SIGNED}
                break
            else
                NEW_SIGNED="Wrong input (type yes/no)"
            fi
        done

        switch_to ${IMAGE}
    }

    AVAILABLE_DESKTOPS="cosmic \
                        gnome \
                        kde"

    IMAGE_TOOL={{ WITH }}
    if [ "${IMAGE_TOOL}" != "bootc" ] && [ "${IMAGE_TOOL}" != "rpm-ostree" ]; then
        echo "Wrong input."
        exit 0
    fi

    # if bootc
    if [ "${IMAGE_TOOL}" = "bootc" ]; then
        CUR_IMAGE_NO_PREFIX=$(bootc status --format=json | jq -r '.status.booted.image.image.image')
        SIGNED="yes"
    # else rpm-ostree
    else
        CUR_IMAGE=$(rpm-ostree status -b 2> /dev/null | grep '●' | cut -d' ' -f2)

        PREFIX_SIGNED="ostree-image-signed:docker://"
        PREFIX_UNSIGNED="ostree-unverified-registry:"

        if grep -q "${PREFIX_SIGNED}" <<< ${CUR_IMAGE}; then
            PREFIX=${PREFIX_SIGNED}
            SIGNED="yes"
        elif grep -q "${PREFIX_UNSIGNED}" <<< ${CUR_IMAGE}; then
            PREFIX=${PREFIX_UNSIGNED}
            SIGNED="no"
        else
            echo "Couldn't get the prefix of current image."
            exit 1
        fi

        CUR_IMAGE_NO_PREFIX=$(sed "s|${PREFIX}||" <<< ${CUR_IMAGE})
    fi

    SOURCE=$(cut -d'/' -f1 <<< ${CUR_IMAGE_NO_PREFIX})
    OWNER=$(cut -d'/' -f2 <<< ${CUR_IMAGE_NO_PREFIX})
    IMAGE=$(echo ${CUR_IMAGE_NO_PREFIX} | cut -d'/' -f3 | cut -d':' -f1)
    TAG=$(cut -d':' -f2 <<< ${CUR_IMAGE_NO_PREFIX})

    REBOOT="no"

    IMAGE_TYPE=$(cut -d'-' -f1-2 <<< ${IMAGE})
    for desktop in ${AVAILABLE_DESKTOPS}; do
        AVAILABLE_IMAGES+="${IMAGE_TYPE}-${desktop} "
    done

    show_info "Current image:" "Choose your new ${bold}IMAGE${normal}."

    MENU_IMAGES=$(sed -E "s/${IMAGE}//;s/[[:space:]]\{2,\}/[[:space:]]/" <<< ${AVAILABLE_IMAGES})

    if [ "${SIGNED}" == "no" ]; then
        OPTION=$(ugum choose "current image, but signed" ${MENU_IMAGES} "..something else")
    else
        OPTION=$(ugum choose ${MENU_IMAGES} "..something else")
    fi

    if [ "${OPTION}" == "current image, but signed" ]; then
        SIGNED="yes"
        switch_to ${IMAGE}
    elif [ "${OPTION}" == "${IMAGE}" ]; then
        echo "Already on the same image."
        exit 0
    elif [ "${OPTION}" == "..something else" ]; then
        show_info "Current image:"
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

# GRUB stuff
grub ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    auto-hide-with-windows () {
        if /usr/bin/pkexec grub2-editenv list | grep -q 'menu_auto_hide=2'; then
            echo "Already set."
            exit 0
        else
            if /usr/bin/pkexec grub2-editenv - set menu_auto_hide=2; then
                echo "Done."
                exit 0
            else
                echo "There was some error. Do you have privileges ?"
                exit 1
            fi
        fi
    }

    use-blscfg () {
        /usr/bin/pkexec grub2-switch-to-blscfg
        /usr/bin/pkexec grub2-mkconfig -o /etc/grub2.cfg
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "use-blscfg" "auto-hide-with-windows")
    fi

    if [ "${OPTION}" == "use-blscfg" ]; then
        use-blscfg
    elif [ "${OPTION}" == "auto-hide-with-windows" ]; then
        auto-hide-with-windows
    else
        echo "No changes applied."
        exit 0
    fi

# Kernel stuff
kernel ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    enable-trim-with-luks () {
        rpm-ostree kargs --append-if-missing=rd.luks.options=discard

        TRIM_TIMER="fstrim.timer"
        if ! systemctl is-enabled ${TRIM_TIMER} &> /dev/null; then
            systemctl enable ${TRIM_TIMER}
        fi
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "enable-trim-with-luks")
    fi

    if [ "${OPTION}" == "enable-trim-with-luks" ]; then
        enable-trim-with-luks
    else
        echo "No changes applied."
        exit 0
    fi
