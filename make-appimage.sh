#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/org.chipass.ChiPass.png
export DESKTOP=/usr/share/applications/org.chipass.ChiPass.desktop
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun \
	/usr/bin/ChiPass* \
	/usr/lib/libpcsclite_real.so*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds
quick-sharun --test ./dist/*.AppImage
