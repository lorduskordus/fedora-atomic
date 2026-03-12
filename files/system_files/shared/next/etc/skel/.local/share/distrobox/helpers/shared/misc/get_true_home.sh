#!/usr/bin/env bash

# Example how to get host home in all distroboxes

TRUE_HOME="${DISTROBOX_HOST_HOME:-$HOME}"

echo "-------- Example how to get host home in all distroboxes --------"
echo
echo 'TRUE_HOME="${DISTROBOX_HOST_HOME:-$HOME}"'
echo
echo "\$DISTROBOX_HOST_HOME  =  ${DISTROBOX_HOST_HOME}"
echo "\$HOME                 =  ${HOME}"
echo "\$TRUE_HOME            =  ${TRUE_HOME}"
