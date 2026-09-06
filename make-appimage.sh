#!/bin/sh

set -eu

ARCH=$(uname -m)

# Extract version components from src/CMakeLists.txt
MAJOR=$(grep -i "set(KEEPASSXC_VERSION_MAJOR" src/CMakeLists.txt | cut -d '"' -f 2 || echo "2")
MINOR=$(grep -i "set(KEEPASSXC_VERSION_MINOR" src/CMakeLists.txt | cut -d '"' -f 2 || echo "7")
PATCH=$(grep -i "set(KEEPASSXC_VERSION_PATCH" src/CMakeLists.txt | cut -d '"' -f 2 || echo "0")

VERSION="${MAJOR}.${MINOR}.${PATCH}"

export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/chipass.png
export DESKTOP=/usr/share/applications/org.chipass.ChiPass.desktop
export ALWAYS_SOFTWARE=1

# On Arch Linux qt5-wayland also adds the server-side plugins
# Remove them so that they do not get deployed
rm -rf /usr/lib/qt6/plugins/wayland-graphics-integration-server 2>/dev/null || true
rm -rf /usr/lib/qt/plugins/wayland-graphics-integration-server 2>/dev/null || true

# Deploy dependencies
quick-sharun \
	/usr/bin/chipass* \
	/usr/lib/chipass \
	/usr/lib/keepassxc \
	/usr/lib/libpcsclite_real.so*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds
quick-sharun --test ./dist/*.AppImage
