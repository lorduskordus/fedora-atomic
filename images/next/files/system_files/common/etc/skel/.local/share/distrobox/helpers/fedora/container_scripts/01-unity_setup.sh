#!/usr/bin/env bash

# Installs Unity and customizes its launcher to use discrete GPU and MangoHUD (for FPS limit)

use_discrete_gpu () {
    DGPU_STR="PrefersNonDefaultGPU=true"

    echo "- Making it use discrete GPU"

    if grep -qF "$DGPU_STR" "$DESKTOP_FILE"; then
        echo "  - Already enabled."
    else
        echo "  - Enabling it."
        echo "PrefersNonDefaultGPU=true" | sudo tee -a "$DESKTOP_FILE" > /dev/null
    fi
}

use_mangohud () {
    ORIGINAL_EXEC_STR='Exec=/opt/unityhub/unityhub %U'
    NEW_EXEC_STR='Exec=/usr/bin/mangohud /opt/unityhub/unityhub %U'

    echo "- Making it use MangoHUD"

    if ! command -v mangohud &> /dev/null; then
        echo "  - Not installed, installing..."
        sudo dnf install -y mangohud
    fi

    if grep -qF "$ORIGINAL_EXEC_STR" "$DESKTOP_FILE"; then
        echo "  - Found correct Exec string in the launcher."
        echo "      - Enabling it."
        sudo sed -i "s:$ORIGINAL_EXEC_STR:$NEW_EXEC_STR:" "$DESKTOP_FILE"
    elif grep -qF "$NEW_EXEC_STR" "$DESKTOP_FILE"; then
        echo "  - Found correct Exec string in the launcher."
        echo "    - Already enabled."
    else
        echo "  - Error: Could not find Exec string '$ORIGINAL_EXEC_STR' in the launcher."
        echo "    - Someone upstream probably f'd up and changed the string."
        exit 1
    fi
}

export_app () {
    echo "- Exporting app"

    distrobox-export --app unityhub
}

install_unityhub () {
    echo "- Installing unityhub"

    if ! command -v unityhub &> /dev/null; then
        echo "  - Not installed, installing..."

        # Import .repo
        sudo sh -c 'echo -e "[unityhub]\nname=Unity Hub\nbaseurl=https://hub.unity3d.com/linux/repos/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key\nrepo_gpgcheck=1" > /etc/yum.repos.d/unityhub.repo'

        # Install unityhub
        sudo dnf install -y unityhub
    else
        echo "  - Already installed."
    fi

    if [ -f "$DESKTOP_FILE" ]; then
        echo "  - Found the launcher '$DESKTOP_FILE'."
    else
        echo "  - Error: Could not find the launcher '$DESKTOP_FILE'."
        echo "      - Someone upstream f'd up and changed how Unity is installed."
        exit 1
    fi
}

setup_unity () {
    DESKTOP_FILE="/usr/share/applications/unityhub.desktop"

    echo "Install Unity and make it use discrete GPU and MangoHUD"

    install_unityhub
    use_discrete_gpu
    use_mangohud
    export_app
}

setup_unity
