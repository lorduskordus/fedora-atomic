# GNOME stuff
gnome ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    copy-monitor-settings-to-gdm () {
        if [ -s ~/.config/monitors.xml ]; then
            /usr/bin/pkexec install -o gdm -g gdm -m 644 ~/.config/monitors.xml ~gdm/.config/
        else
            echo "Missing monitor configuration."
            exit 1
        fi
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "copy-monitor-settings-to-gdm")
    fi

    if [ "${OPTION}" == "copy-monitor-settings-to-gdm" ]; then
        copy-monitor-settings-to-gdm
    else
        echo "No changes applied."
        exit 0
    fi
