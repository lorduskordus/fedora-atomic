#!/usr/bin/env bash

# Installs Steam, Lutris and MangoHUD

export_apps () {
    EXPORT_APPS="steam lutris"

    for app in $EXPORT_APPS; do
        distrobox-export --app "$app"
    done
}

install_packages () {
    PACKAGES="steam lutris mangohud"
    LUTRIS_DEPS="pciutils vulkan-tools xterm python3-gobject python3-cairo kde-gtk-config"

    echo "Installing:"
    echo "  - Main packages        ==  ${PACKAGES}"
    echo "  - Lutris dependencies  ==  ${LUTRIS_DEPS}"

    sudo dnf install -y ${PACKAGES} ${LUTRIS_DEPS}
}

setup_gaming () {
    echo "Install Steam, Lutris and MangoHUD"

    install_packages
    export_apps
}

setup_gaming
