#!/usr/bin/env bash

# Fully prepares Fedora

PACKAGES="bash-completion bc bzip2 curl diffutils dnf-plugins-core findutils fish glibc-all-langpacks glibc-locale-source gnupg2 gnupg2-smime hostname iproute iputils keyutils krb5-libs less lsof man-db man-pages mtr ncurses nss-mdns openssh-clients pam passwd pigz pinentry procps-ng rsync shadow-utils sudo tcpdump time traceroute tree tzdata unzip util-linux vte-profile wget which whois words xorg-x11-xauth xz zip mesa-dri-drivers mesa-vulkan-drivers vulkan zsh vim ripgrep script"

# Update system and install core packages
sudo dnf -y upgrade
sudo dnf install -y ${PACKAGES}

# Set up cleaner Distrobox integration
sudo dnf copr enable -y kylegospo/distrobox-utils
sudo dnf install -y xdg-utils-distrobox adw-gtk3-theme
sudo ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak

# Install RPMFusion for hardware accelerated encoding/decoding
sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf install -y intel-media-driver nvidia-vaapi-driver
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

sudo dnf clean all
