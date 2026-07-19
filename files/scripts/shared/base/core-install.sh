#!/usr/bin/env bash

# Installs all core stuff

set -euo pipefail

# Install ublue-os-udev-rules, android-udev-rules, ublue-os-update-services,..
install-ublue-config () {
    # Download Universal Blue packages config zip
    get-ublue-packages () {
        echo -e "\033[90mDownloading Universal Blue packages config zip file\033[0m"
        curl -fLs --create-dirs \
            https://github.com/ublue-os/packages/archive/refs/heads/main.zip \
            -o /tmp/ublue-config/packages.zip

        echo -e "\033[90mUnzipping the file\033[0m"
        unzip -q /tmp/ublue-config/packages.zip -d /tmp/ublue-config/
        rm /tmp/ublue-config/packages.zip
    }

    # Universal Blue udev rules
    install-ublue-rules () {
        echo -e "\033[90mCopying udev rules from Universal Blue\033[0m"
        cp /tmp/ublue-config/packages-main/packages/ublue-os-udev-rules/src/udev-rules.d/*.rules \
            /usr/lib/udev/rules.d/
    }

    # Add plugdev group to sysusers.d (needed for Yubikey udev rules) (not done in Ublue)
    add-plugdev-group () {
        echo -e "\033[90mAdd plugdev group to sysusers.d (not done in Ublue)\033[0m"
        echo "g plugdev -" > /usr/lib/sysusers.d/30-append-plugdev-group.conf
    }

    # Game-device-udev rules
    install-game-device-rules () {
        echo -e "\033[90mDownloading game-device-udev zip file\033[0m"
        curl -fLs --create-dirs \
            https://codeberg.org/fabiscafe/game-devices-udev/archive/main.zip \
            -o /tmp/ublue-config/game-devices-udev/main.zip

        echo -e "\033[90mUnzipping the file\033[0m"
        unzip -q /tmp/ublue-config/game-devices-udev/main.zip \
            -d /tmp/ublue-config/game-devices-udev/

        rm /tmp/ublue-config/game-devices-udev/main.zip

        echo -e "\033[90mCopying udev rules from Game-device-udev\033[0m"
        find /tmp/ublue-config/game-devices-udev \
            -type f \
            -name '*.rules' \
            -exec cp {} /usr/lib/udev/rules.d/ \;

        echo -e "\033[90mPutting uinput to be loaded as a module in modules-load.d\033[0m"
        echo "uinput" > /usr/lib/modules-load.d/uinput.conf
    }

    # Android udev rule
    install-android-rules () {
        echo -e "\033[90mDownloading Android udev rule\033[0m"
        curl -fLs --create-dirs \
            https://raw.githubusercontent.com/M0Rf30/android-udev-rules/refs/heads/main/51-android.rules \
            -o /usr/lib/udev/rules.d/51-android.rules

        echo -e "\033[90mAdding adbusers group to sysusers.d\033[0m"
        echo "g adbusers - -" > /usr/lib/sysusers.d/android-udev.conf
    }

    # Flatpak updaters (rpm-ostree updater omitted because bootc update is used instead)
    install-flatpak-updaters () {
        echo -e "\033[90mCopying flatpak updater\033[0m"
        cp /tmp/ublue-config/packages-main/packages/ublue-os-update-services/src/usr/lib/systemd/system/flatpak-system-update.timer \
            /usr/lib/systemd/system/flatpak-system-update.timer

        cp /tmp/ublue-config/packages-main/packages/ublue-os-update-services/src/usr/lib/systemd/system/flatpak-system-update.service \
            /usr/lib/systemd/system/flatpak-system-update.service

        cp /tmp/ublue-config/packages-main/packages/ublue-os-update-services/src/usr/lib/systemd/user/flatpak-user-update.timer \
            /usr/lib/systemd/user/flatpak-user-update.timer

        cp /tmp/ublue-config/packages-main/packages/ublue-os-update-services/src/usr/lib/systemd/user/flatpak-user-update.service \
            /usr/lib/systemd/user/flatpak-user-update.service

        echo -e "\033[90mEnabling systemd timers for flatpak updaters\033[0m"
        systemctl --system enable flatpak-system-update.timer
        systemctl --global enable flatpak-user-update.timer
    }

    # Use ZSTD compression for initramfs
    use-zstd-compression () {
        echo 'compress="zstd"' > /usr/lib/dracut/dracut.conf.d/10-compression.conf
    }

    # Remove temporary directory
    remove-ublue-packages () {
        rm -r /tmp/ublue-config/
    }

    get-ublue-packages
    install-ublue-rules
    add-plugdev-group
    install-game-device-rules
    install-android-rules
    install-flatpak-updaters
    use-zstd-compression
    remove-ublue-packages
}

# -------------------------------------------------------------------------------------------------- #
#
# Covering ublue-os/main here
# Add negativo repo, modify its repo priority & replace some packages like HEIF & mesa
# Remove chsh & install oversteer-udev rules, as I don't want to rely on potentially outdated RPM
#
# -------------------------------------------------------------------------------------------------- #

# Add Negativo
add-negativo-repo () {
    dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
}

# Replace Fedora packages with Negativos (Mesa & HEIF)
replace-fedora-negativo () {
    PKGS_INSTALL=(
        libva
        libva-intel-media-driver
        intel-gmmlib
        intel-mediasdk
        mesa-dri-drivers
        mesa-filesystem
        mesa-libEGL
        mesa-libGL
        mesa-libgbm
        mesa-va-drivers
        mesa-vulkan-drivers
    )

    # Manually install dependency for `libheif`, as Negativo upstreamed it
    dnf5 -y \
        --setopt=install_weak_deps=True \
        install \
        libopenjph

    dnf5 -y \
        --setopt=install_weak_deps=True \
        install \
        --repoid=fedora-multimedia \
        libheif

    dnf5 -y \
        --setopt=install_weak_deps=True \
        distro-sync \
        --repo fedora-multimedia \
        "${PKGS_INSTALL[@]}"
}

# Remove chsh
remove-chsh () {
    echo -e "\033[90mRemoving chsh\033[0m"
    rm /usr/bin/chsh
}

# Install Oversteer udev rules
install-oversteer-rules () {
    echo -e "\033[90mDownloading Oversteer udev zip file\033[0m"
    curl -fLs --create-dirs \
        https://github.com/berarma/oversteer/archive/refs/heads/master.zip \
        -o /tmp/oversteer-udev/master.zip

    echo -e "\033[90mUnzipping Oversteer udev zip file\033[0m"
    unzip -q /tmp/oversteer-udev/master.zip -d /tmp/oversteer-udev/
    rm /tmp/oversteer-udev/master.zip

    echo -e "\033[90mCopying Oversteer udev rules\033[0m"
    cp /tmp/oversteer-udev/oversteer-master/data/udev/*.rules \
        /usr/lib/udev/rules.d/

    rm -r /tmp/oversteer-udev/
}

# Remove avif thumbnailer, as HEIF thumbnailer already covers it (not done in Ublue)
remove-avif-thumbnailer () {
    echo -e "\033[90mRemove avif thumbnailer, as HEIF thumbnailer already covers it (not done in Ublue)\033[0m"

    if [ -f /usr/share/thumbnailers/heif.thumbnailer ] &&
       [ -f /usr/share/thumbnailers/avif.thumbnailer ]; then
          rm -f /usr/share/thumbnailers/avif.thumbnailer
    fi
}

# Install adw-gtk3 to skel (not done in Ublue)
install-adw-gtk3 () {
    echo -e "\033[90mInstalling adw-gtk3 theme to skel (not done in Ublue)\033[0m"

    VER=$(
        basename "$(
            curl -Ls -o /dev/null -w %{url_effective} \
                https://github.com/lassekongo83/adw-gtk3/releases/latest
        )"
    )

    curl -fLs --create-dirs \
        "https://github.com/lassekongo83/adw-gtk3/releases/download/${VER}/adw-gtk3${VER}.tar.xz" \
        -o /tmp/adw-gtk3.tar.gz

    mkdir -p /etc/skel/.local/share/themes/
    tar -xf /tmp/adw-gtk3.tar.gz -C /etc/skel/.local/share/themes/

    cp -r /etc/skel/.local/share/themes/* /usr/share/themes/

    rm /tmp/adw-gtk3.tar.gz
}

# Install core packages
install-core-packages () {
    PKGS_REMOVE=(
        default-fonts-cjk-sans
        google-noto-sans-cjk-vf-fonts
    )

    PKGS_INSTALL=(
        # Easy container stuff
        distrobox

        # Fonts
        google-noto-sans-balinese-fonts
        google-noto-sans-cjk-fonts
        google-noto-sans-javanese-fonts
        google-noto-sans-sundanese-fonts

        # Audio/video
        alsa-firmware

        # Thumbnailing
        ffmpegthumbnailer

        # Utilities
        fzf

        # Some additional udev rules
        openrgb-udev-rules
        solaar-udev

        # Yubikey stuff
        pam-u2f
        pam_yubico
        pamu2fcfg
        yubikey-manager

        # Nevim
        gvfs-nfs

        # Regular packages
        libratbag-ratbagd
        zstd
        wireguard-tools
    )

    PKGS_MULTIMEDIA_INSTALL=(
        # Graphics stuff
        intel-vaapi-driver
        libva-utils

        # Codecs
        heif-pixbuf-loader

        # Audio stuff (Negativo)
        pipewire-libs-extra
    )

    dnf5 -y remove \
        --no-autoremove \
        "${PKGS_REMOVE[@]}"

    dnf5 -y \
        --setopt=install_weak_deps=True \
        install \
        "${PKGS_INSTALL[@]}"

    dnf5 -y \
        --setopt=install_weak_deps=True \
        install \
        --repoid=fedora-multimedia \
        "${PKGS_MULTIMEDIA_INSTALL[@]}"
}

# Replaces installed free codecs with non-free ones
swap-non-free-codecs () {
    dnf5 -y swap \
        --from-repo fedora-multimedia \
        ffmpeg-free \
        ffmpeg

    dnf5 -y swap \
        --from-repo fedora-multimedia \
        libfdk-aac-free \
        libfdk-aac

    dnf5 -y swap \
        --from-repo fedora-multimedia \
        libavcodec-free \
        libavcodec

    dnf5 -y \
        --setopt=install_weak_deps=True \
        install \
        --repoid=fedora-multimedia \
        ffmpeg-libs
}

# Workaround OpenCL bug
# https://github.com/ublue-os/main/pull/692
fix-opencl () {
    dnf5 -y swap \
        --from-repo fedora \
        OpenCL-ICD-Loader \
        ocl-icd
}

# Workaround non-working Chinese, Japanese & Korean fonts
fix-chinese-fonts () {
    ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk"
}

# Helper function to bring everything together
install () {
    install-ublue-config
    add-negativo-repo
    replace-fedora-negativo
    remove-chsh
    install-oversteer-rules
    remove-avif-thumbnailer
    install-adw-gtk3
    install-core-packages
    swap-non-free-codecs
    fix-opencl
    fix-chinese-fonts
}

install
