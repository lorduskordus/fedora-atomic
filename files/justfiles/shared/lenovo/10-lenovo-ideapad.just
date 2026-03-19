# Control Ideapad Conservation mode
ideapad-conservation-mode ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    # Sets up rootless conservation mode toggling
    # Can't check if already set up due to permissions on the sudoers.d dir
    setup-rootless() {
        if echo "${SUDOERS_LINE}" | /usr/bin/pkexec tee "${SUDOERS_FILE}" &> /dev/null; then
            echo "Successfuly set up rootless ideapad conservation mode."
        else
            echo "Failed to setup rootless ideapad conservation mode."
        fi
    }

    # Enables conservation mode
    enable() {
        if [ "${CUR_STATE}" == "enabled" ]; then
            echo "Already enabled."
            exit 0
        fi

        if echo 1 | sudo tee ${STATE_FILE} &> /dev/null; then
            echo "Successfuly enabled."
        else
            echo "Failed to enable."
        fi
    }

    # Disables conservation mode
    disable() {
        if [ "${CUR_STATE}" == "disabled" ]; then
            echo "Already disabled."
            exit 0
        fi

        if echo 0 | sudo tee ${STATE_FILE} &> /dev/null; then
            echo "Successfuly disabled."
        else
            echo "Failed to disable."
        fi
    }

    # Get vendor, if not LENOVO, exit
    if [ "$(cat /sys/class/dmi/id/sys_vendor)" != "LENOVO" ]; then
        echo "This PC is not LENOVO, cannot continue."
        exit 0
    fi

    # Get the current state of conservation mode
    STATE_FILE="/sys/bus/platform/drivers/ideapad_acpi/VPC????:??/conservation_mode"
    if [ "$(cat ${STATE_FILE} 2> /dev/null)" == "1" ]; then
        CUR_STATE="enabled"
        CUR_STATE_DISPLAY="${green}${CUR_STATE}${normal}"
    else
        CUR_STATE="disabled"
        CUR_STATE_DISPLAY="${red}${CUR_STATE}${normal}"
    fi

    # Prepare sudoers
    SUDOERS_LINE="ALL ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\\:??/conservation_mode"
    SUDOERS_DIR="/etc/sudoers.d"
    SUDOERS_FILENAME="010-ideapad-conservation_mode"
    SUDOERS_FILE="${SUDOERS_DIR}/${SUDOERS_FILENAME}"

    # Prepare options (except setup-rootless, unfortunate limitation)
    OPTIONS="setup-rootless "
    if [ "${CUR_STATE}" == "disabled" ]; then
        OPTIONS+="enable "
    fi
    if [ "${CUR_STATE}" == "enabled" ]; then
        OPTIONS+="disable "
    fi

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        echo "Conservation mode: ${CUR_STATE_DISPLAY}"
        OPTION=$(ugum choose ${OPTIONS})
    fi

    if [ "${OPTION}" == "setup-rootless" ]; then
        setup-rootless
    elif [ "${OPTION}" == "enable" ]; then
        enable
    elif [ "${OPTION}" == "disable" ]; then
        disable
    else
        echo "No changes applied."
    fi
