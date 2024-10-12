#!/bin/bash

_URL="https://github.com/espressif/crosstool-NG/releases/download"
_VERSION=14.2.0_20240906
XTENSA_TOOLCHAIN_URL="$_URL/esp-$_VERSION/xtensa-esp-elf-$_VERSION-x86_64-linux-gnu.tar.xz"

# Download & install XTensa cross-compiler
if [[ ! -d "/opt/xtensa" ]]; then
(
	mkdir -p /tmp/xtensa-esp32-download/
	cd /tmp/xtensa-esp32-download/
	wget -qO "xtensa-esp32.tar.xz" "$XTENSA_TOOLCHAIN_URL"
	mkdir -p /opt/xtensa
	tar -xf "xtensa-esp32.tar.xz" -C "/opt/xtensa"
	echo 'export PATH=$PATH:/opt/xtensa/xtensa-esp32-elf/bin' > /etc/profile.d/xtensa.sh
)
fi

