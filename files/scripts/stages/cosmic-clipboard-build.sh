#!/usr/bin/env bash

# Builds COSMIC Clipboard Manager

REPO="https://github.com/cosmic-utils/clipboard-manager"
REPO_NAME=$(cut -d '/' -f 5 <<< ${REPO})
DEPS="git rust cargo just libxkbcommon-devel"
PREFIX="/out"

dnf5 install -y ${DEPS}

git clone ${REPO}
cd ${REPO_NAME}

just build-release
just prefix=${PREFIX} install
