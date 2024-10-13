#!/bin/bash

[[ "$VM_INSTALL" != "null" ]] || exit 0

# give student user permissions to serial devices
usermod -a -G dialout student

# install req. tools for the student user
function _install_user_config() {
	pipx ensurepath
	pipx install esptool
	pipx install pyserial

	if [[ "$VM_DEBUG" -gt 1 ]]; then
		mkdir -p ~/nuttxspace && cd ~/nuttxspace
		[[ -d nuttx ]] || git clone --branch=nuttx-12.5.1 https://github.com/apache/incubator-nuttx.git nuttx
		[[ -d apps ]] || git clone --branch=nuttx-12.5.1 https://github.com/apache/incubator-nuttx-apps.git apps
		mkdir -p esp-bins
		curl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32.bin" -o esp-bins/bootloader-esp32.bin
		curl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32.bin" -o esp-bins/partition-table-esp32.bin
	fi
}
echo "$(declare -f _install_user_config); _install_user_config" | su -c bash student

