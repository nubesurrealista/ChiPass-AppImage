#!/bin/sh

set -eu

ARCH=$(uname -m)

VERSION=$(build/src/chipass --version 2>/dev/null | awk '{print $2}' || echo "latest")

export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/local/share/icons/hicolor/256x256/apps/chipass.png
export DESKTOP=/usr/local/share/applications/org.chipass.ChiPass.desktop
export ALWAYS_SOFTWARE=1

# on archlinux qt5-wayland also adds the server side plugins
# remove them so that they do not get deployed
rm -rf /usr/lib/qt6/plugins/wayland-graphics-integration-server 2>/dev/null || true
rm -rf /usr/lib/qt/plugins/wayland-graphics-integration-server 2>/dev/null || true

DESTDIR=/ cmake --install build

# Deploy dependencies
quick-sharun \
	/usr/local/bin/chipass* \
	/usr/local/lib/chipass* \
	/usr/lib/libpcsclite*.so*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
