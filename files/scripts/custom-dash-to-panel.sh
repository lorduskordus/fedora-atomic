#!/usr/bin/env bash

# Sets rounded corners for a horizontal Dash-to-Panel layout.

set -euo pipefail

# Setup variables
ADD_PANEL_HEIGHT=8 # Should be exactly twice of BORDERS
BORDERS=4
BORDER_RADIUS=10
EXTENSION_PATH="/usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com"

echo "Setting up custom Dash to Panel.."

if [ ! -d "${EXTENSION_PATH}" ]; then
    echo "Dash-to-Panel is not installed."
    exit 1
fi

# Alter panel.js
sed -i "s|const panelSize.*|const panelSize = PanelSettings.getPanelSize(SETTINGS, this.monitor.index) + ${ADD_PANEL_HEIGHT};|" "${EXTENSION_PATH}/panel.js"

# Prepare stylesheet.css addition
ADD_STYLESHEET=\
"/*Customized, issue 1819*/
#dashtopanelScrollview .app-well-app:hover .dtp-container,
#dashtopanelScrollview .app-well-app:focus .dtp-container,
#dashtopanelScrollview .app-well-app .dtp-container > StWidget {
  border-radius: ${BORDER_RADIUS}px;
}
#dashtopanelScrollview .dash-item-container > StWidget { 
  border-top: ${BORDERS}px;
  border-bottom: ${BORDERS}px;
}
/*Customized, issue 1819*/"

# Alter stylesheet.css

# Check if we added customizations to stylesheet.css before..
if ! grep -qF "/*Customized, issue 1819*/" "${EXTENSION_PATH}/stylesheet.css"; then
    # ..no, add them.
    echo -e "\n${ADD_STYLESHEET}" >> "${EXTENSION_PATH}/stylesheet.css"
else
    # ..yes, replace them.
    awk -i inplace -v ADD_STYLESHEET="${ADD_STYLESHEET}" '/\/\*Customized, issue 1819\*\// {
        if (!inside_block) {
            print ADD_STYLESHEET;
            inside_block = 1;
            next;
        } else {
            inside_block = 0;
            next;
        }
    } !inside_block' "${EXTENSION_PATH}/stylesheet.css"
fi

echo "Done."
