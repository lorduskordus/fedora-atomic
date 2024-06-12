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
