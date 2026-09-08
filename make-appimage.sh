#!/bin/sh

set -eu

ARCH=$(uname -m)

# Extract version from src/CHANGELOG.md matching ChiPassVersion.cmake
VERSION=$(sed -n '1s/^Version \([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*/\1/p' src/CHANGELOG.md)

export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/org.chipass.ChiPass.png
export DESKTOP=/usr/share/applications/org.chipass.ChiPass.desktop
export ALWAYS_SOFTWARE=1

# On Arch Linux qt5-wayland also adds the server-side plugins
# Remove them so that they do not get deployed
rm -rf /usr/lib/qt6/plugins/wayland-graphics-integration-server 2>/dev/null || true
rm -rf /usr/lib/qt/plugins/wayland-graphics-integration-server 2>/dev/null || true

# Deploy dependencies
quick-sharun \
	/usr/bin/ChiPass* \
	/usr/lib/libpcsclite_real.so*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds
quick-sharun --test ./dist/*.AppImage
