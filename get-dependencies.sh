#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	git \
	ccache \
	cmake \
	ninja \
	qt6-base \
	qt6-svg \
	qt6-tools \
	qt6-5compat \
	readline \
	botan \
	argon2 \
	minizip \
	zlib \
	qrencode \
	pcsclite \
	libusb \
	xorg-server-xvfb \
	xclip \
	libxi \
	libxtst \
	asciidoctor

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

echo "Building ChiPass..."
git clone https://codeberg.org/ChiPass/ChiPass.git src
cmake -S src -B build -G Ninja \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=Release \
	-DWITH_CCACHE=ON \
	-DWITH_XC_ALL=ON \
	-DWITH_GUI_TESTS=OFF
cmake --build build

echo "Installing ChiPass globally..."
DESTDIR=/ cmake --install build
