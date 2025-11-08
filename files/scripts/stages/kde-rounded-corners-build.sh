#!/usr/bin/env bash

# Builds KDE-Rounded-Corners

REPO="https://github.com/matinlotfali/KDE-Rounded-Corners"
REPO_NAME=$(cut -d '/' -f 5 <<< ${REPO})
DEPS="git cmake gcc-c++ extra-cmake-modules kwin-devel kf6-kconfigwidgets-devel libepoxy-devel kf6-kcmutils-devel kf6-ki18n-devel qt6-qtbase-private-devel wayland-devel libdrm-devel"
PREFIX="/out"

dnf5 install -y ${DEPS}

git clone ${REPO}
cd ${REPO_NAME}

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
cmake --build . -j
make install
