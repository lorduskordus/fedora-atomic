# Virtualization stuff
virtualization ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    allow-qemu-home-access () {
        pkexec setfacl -m u:qemu:rx ${HOME_VAR}
    }

    revoke-qemu-home-access () {
        # pkexec setfacl -x u:qemu ${HOME_VAR}
        pkexec setfacl -b ${HOME_VAR}
    }

    add-to-libvirt-group () {
        pkexec usermod -aG libvirt ${USER_VAR}
    }

    USER_VAR=${USER}
    HOME_VAR=${HOME}

    if getfacl ${HOME_VAR} 2> /dev/null | grep -q user:qemu:r-x; then
        echo "QEMU access to '${HOME_VAR}': ${green}YES${normal}"
        ACTION_VAR="revoke-qemu-home-access"
    else
        echo "QEMU access to '${HOME_VAR}': ${red}NO${normal}"
        ACTION_VAR="allow-qemu-home-access"
    fi

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "${ACTION_VAR}" "add-to-libvirt-group" "cancel")
    fi

    if [ "${OPTION}" == "${ACTION_VAR}" ]; then
        ${ACTION_VAR}
    elif [ "${OPTION}" == "add-to-libvirt-group" ]; then
        add-to-libvirt-group
    else
        echo "No changes applied."
        exit 0
    fi
