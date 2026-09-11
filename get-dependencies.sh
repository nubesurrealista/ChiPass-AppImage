#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	appstream \
	argon2 \
	asciidoctor \
	botan \
	ccache \
	cmake \
	kvantum \
	libusb \
	libxi \
	libxtst \
	lxqt-qtplugin \
	minizip \
	ninja \
	pcsclite \
	qrencode \
	qt6-5compat \
	qt6ct \
	qt6-svg \
	qt6-tools \
	readline \
	xclip \
	zlib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

echo "Building ChiPass..."
REPO=https://codeberg.org/ChiPass/ChiPass.git && \
git clone $REPO --single-branch --branch \
$(git ls-remote --tags $REPO | grep -wv "}$" | cut -d/ -f3 | sort -V | tail -n1) src
cmake -S src -B build -G Ninja \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=Release \
	-DCHIPASS_COMPILER_LAUNCHER=ccache \
	-DCHIPASS_WITH_UPDATE_CHECK=OFF \
	-DCHIPASS_WITH_GUI_TESTS=OFF \
	-DCHIPASS_WITH_TESTS=OFF
cmake --build build

echo "Installing ChiPass globally..."
DESTDIR=/ cmake --install build

sed -n '1s/^Version \([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*/\1/p' src/CHANGELOG.md > ~/version
