#!/usr/bin/env bash

# Sets up, installs and fully integrates the AM package manager
#
# Stuff installed
#  - 'am'                  - AppImage Manager
#  - 'appimageupdatetool'  - Support for AppImage diff updates
#  - 'sas'                 - Simple AppImage Sandbox (deps: 'dwarfs', 'squashfuse')
#  - 'am-gui'              - GUI Store for AM
#
# Stuff set up
#  - Automatic updates (systemd timer & service)
#  - Disables update notifications

set -euo pipefail

# Installs 'am' (AppImage Manager) (main branch)
install-am-main() {
  echo -e "\e[1m\e[38;5;214mInstalling 'am' (AppImage Manager) from 'main' branch\e[0m"

  # Download latest main branch archive
  curl -fLs --create-dirs \
    https://github.com/ivan-hc/AM/archive/refs/heads/main.zip \
    -o /tmp/am.zip

  # Create temporary directory
  mkdir -p /tmp/am

  # Extract archive
  unzip -q /tmp/am.zip -d /tmp/am/

  # Install main executable
  cp /tmp/am/AM-main/APP-MANAGER /usr/bin/am
  chmod +x /usr/bin/am

  # Install modules
  mkdir -p /usr/lib/am/modules/
  cp /tmp/am/AM-main/modules/* /usr/lib/am/modules/
  chmod +x /usr/lib/am/modules/*

  # Cleanup
  rm -r /tmp/am/
  rm /tmp/am.zip
}

# Installs 'am' (AppImage Manager) (latest release)
install-am-release() {
  echo -e "\e[1m\e[38;5;214mInstalling 'am' (AppImage Manager)\e[0m"

  # Get the latest version
  VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ivan-hc/AM/releases/latest))

  # Download latest version archive
  curl -fLs --create-dirs \
    https://github.com/ivan-hc/AM/archive/refs/tags/${VER}.zip \
    -o /tmp/am.zip

  # Create temporary directory
  mkdir -p /tmp/am

  # Extract archive
  unzip -q /tmp/am.zip -d /tmp/am/

  # Install main executable
  cp /tmp/am/AM-${VER}/APP-MANAGER /usr/bin/am
  chmod +x /usr/bin/am

  # Install modules
  mkdir -p /usr/lib/am/modules/
  cp /tmp/am/AM-${VER}/modules/* /usr/lib/am/modules/
  chmod +x /usr/lib/am/modules/*

  # Cleanup
  rm -r /tmp/am/
  rm /tmp/am.zip
}

# Installs 'appimageupdatetool' for diff updates
install-update-tool() {
  echo -e "\e[1m\e[38;5;214mInstalling 'appimageupdatetool' for AppImage diff updates\e[0m"

  # Get latest release version tag
  VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} \
    https://github.com/pkgforge-dev/AppImageUpdate-Enhanced-Edition/releases/latest))

  # Download tool and make executable
  curl -fLs --create-dirs \
    https://github.com/pkgforge-dev/AppImageUpdate-Enhanced-Edition/releases/download/${VER}/appimageupdatetool+validate-x86_64.AppImage \
    -o /usr/bin/appimageupdatetool

  chmod +x /usr/bin/appimageupdatetool
}

# Installs 'sas' (Simple AppImage Sandbox)
install-sas() {
  echo -e "\e[1m\e[38;5;214mInstalling 'simple-appimage-sandbox', aka 'sas' sandboxing tool for AppImages\e[0m"

  # Download sandbox script (script version avoids SUID libfuse dependency from the AppImage build)
  curl -fLs --create-dirs \
    https://raw.githubusercontent.com/Samueru-sama/simple-appimage-sandbox/refs/heads/main/sas.sh \
    -o /usr/bin/simple-appimage-sandbox

  chmod +x /usr/bin/simple-appimage-sandbox

  # Create convenient alias command
  ln -sf /usr/bin/simple-appimage-sandbox /usr/bin/sas

  ########################################
  # Install missing dependencies for 'sas'
  ########################################

  # Install 'dwarfs'
  curl -fLs --create-dirs \
    https://pkgs.pkgforge.dev/dl/bincache/x86_64-linux/dwarfs/standalone/dwarfs/raw.dl \
    -o /usr/bin/dwarfs

  chmod +x /usr/bin/dwarfs

  # Install 'squashfuse'
  curl -fLs --create-dirs \
    https://pkgs.pkgforge.dev/dl/bincache/x86_64-linux/squashfuse/nixpkgs/squashfuse/raw.dl \
    -o /usr/bin/squashfuse

  chmod +x /usr/bin/squashfuse
}

# Installs 'am-gui' (GUI store for AM)
install-gui() {
  echo -e "\e[1m\e[38;5;214mInstalling 'am-gui' (GUI store for AM)\e[0m"

  # Get latest release version tag
  VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} \
    https://github.com/Shikakiben/AM-GUI/releases/latest))

  VER_SHORT=$(cut -d@ -f1 <<< ${VER})

  # Download the app and make it executable
  curl -fLs --create-dirs \
    https://github.com/Shikakiben/AM-GUI/releases/download/${VER}/AM-GUI-${VER_SHORT}-anylinux-x86_64.AppImage \
    -o /usr/bin/am-gui

  chmod +x /usr/bin/am-gui

  # Get the launcher .desktop file
  curl -fLs --create-dirs \
    https://raw.githubusercontent.com/Shikakiben/AM-GUI/refs/heads/main/AM-GUI.desktop \
    -o /usr/share/applications/AM-GUI.desktop

  # Get the launcher icon file
  curl -fLs --create-dirs \
    https://raw.githubusercontent.com/Shikakiben/AM-GUI/refs/heads/main/AM-GUI.png \
    -o /usr/share/icons/hicolor/512x512/apps/AM-GUI.png
}

# Sets up 'am' completion for 'bash' and 'fish'
setup-completion() {
  echo -e "\e[1m\e[38;5;214mInstalling 'am' bash completion\e[0m"

  mkdir -p "/usr/share/bash-completion/completions/"
  echo 'complete -W "$(cat "${XDG_DATA_HOME:-$HOME/.local/share}/AM/list" 2>/dev/null)" am' \
    > "/usr/share/bash-completion/completions/am"

  # Proceed only if 'fish' is installed
  if command -v fish &> /dev/null; then
    echo -e "\e[1m\e[38;5;214mInstalling 'am' fish completion\e[0m"

    mkdir -p "/usr/share/fish/vendor_completions.d/"

cat << 'EOF' > "/usr/share/fish/vendor_completions.d/am"
set data_home "$XDG_DATA_HOME"
if test -z "$data_home"
    set data_home "$HOME/.local/share"
end
complete -c am -f -a "(cat "$data_home/AM/list" 2>/dev/null)"
EOF

  fi
}

# Sets up automatic updates for 'am' by creating & enabling a systemd timer & service
setup-auto-updates() {
  echo -e "\e[1m\e[38;5;214mWriting & enabling 'am' AppImages auto-update timer\e[0m"

# Write systemd user service
cat << 'EOF' > /usr/lib/systemd/user/am-update.service
[Unit]
Description=AM Automatic Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
Environment="NO_COLOR=1"
ExecCondition=/bin/bash -c 'if ps aux | grep -v grep | grep -E -q " /sbin/am | /bin/am | /usr/sbin/am | /usr/bin/am | am "; then exit 1; else exit 0; fi'
ExecCondition=/bin/bash -c '[[ "$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered | cut -c 3-)" == @(2|4) ]]'
ExecStart=/usr/bin/am update
EOF

# Write systemd user timer
cat << 'EOF' > /usr/lib/systemd/user/am-update.timer
[Unit]
Description=AM Automatic Update Trigger

[Timer]
RandomizedDelaySec=10m
OnBootSec=2m
OnCalendar=*-*-* 4:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

  # Enable timer globally
  systemctl --global enable am-update.timer
}

# Replaces 'wget2' with 'wget1' (better 'am' progress indicators)
replace-wget() {
  echo -e "\e[1m\e[38;5;214mReplacing 'wget2' with 'wget1' for better 'am' progress indicators\e[0m"

  dnf5 -y remove \
    wget2 wget2-wget
  dnf5 -y install \
    wget1 wget1-wget
}

# Disables 'am' update notifications
disable-notifications() {
  echo -e "\e[1;31mDisabling 'am' update notifications\e[0m"

  mkdir -p /etc/skel/.local/share/AM/
  touch /etc/skel/.local/share/AM/disable-notifications
}

# Sets locale to English as a temporary fix for AM-GUI
set-english-locale() {
  echo -e "\e[1;31mSetting English locale for 'am' to fix AM-GUI\e[0m"

  mkdir -p /etc/skel/.local/share/AM/
  echo "en" > /etc/skel/.local/share/AM/locale
}

# Helper function to bring everything together
install() {
  install-am-release
  install-update-tool
  install-sas
  install-gui

  setup-completion
  setup-auto-updates

  replace-wget
  disable-notifications
  set-english-locale # Temporary fix
}

install
