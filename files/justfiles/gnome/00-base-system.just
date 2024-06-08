# Mirror current monitor settings for GDM (GNOME's login screen)
copy-monitor-to-gdm:
    #!/usr/bin/env bash
    if [ -s ~/.config/monitors.xml ]; then
        pkexec install -o gdm -g gdm -m 644 ~/.config/monitors.xml ~gdm/.config/
    else
        echo "Missing monitor configuration."
        exit 1
    fi
