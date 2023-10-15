#!/bin/bash

XTENSA_TOOLCHAIN_URL="https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/xtensa-esp32-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz"

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

