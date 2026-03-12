#!/usr/bin/env bash

# Mirrors what Universal Blue fedora-toolbox is doing
# ! This is not fully valid, it sits here only as a point of reference !

echo "Mirroring Universal Blue fedora-toolbox stuff"

sudo dnf -y upgrade
sudo dnf install -y dnf5 bash-completion bc bzip2 curl diffutils dnf-plugins-core findutils fish glibc-all-langpacks glibc-locale-source gnupg2 gnupg2-smime hostname iproute iputils keyutils krb5-libs less lsof man-db man-pages mtr ncurses nss-mdns openssh-clients pam passwd pigz pinentry procps-ng rsync shadow-utils sudo tcpdump time traceroute tree tzdata unzip util-linux vte-profile wget which whois words xorg-x11-xauth xz zip mesa-dri-drivers mesa-vulkan-drivers vulkan zsh vim ripgrep script
sudo dnf clean all

# Set up dependencies
git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox
sudo cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec
sudo wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn
sudo chmod +x /usr/bin/host-spawn
sudo rm -drf /tmp/distrobox
sudo dnf install -y 'dnf-command(copr)'
sudo dnf clean all

# Set up cleaner Distrobox integration
sudo dnf copr enable -y kylegospo/distrobox-utils
sudo dnf install -y xdg-utils-distrobox adw-gtk3-theme
sudo ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak
sudo dnf clean all

# Install RPMFusion for hardware accelerated encoding/decoding
sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y intel-media-driver nvidia-vaapi-driver
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf clean all

sudo rm -rf /tmp/*
