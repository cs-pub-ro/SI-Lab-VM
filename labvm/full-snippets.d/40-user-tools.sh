#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

[[ "$VM_INSTALL" != "null" ]] || exit 0

# give student user permissions to serial devices
usermod -a -G dialout student

# install req. tools for the student user
function _install_user_config() {
	set -e
	pipx ensurepath
	pipx install esptool
	pipx install pyserial

	# set git identities
	git config --global user.email "$USER@si-lab-vm.local"
	git config --global user.name "SI ${USER}"

	if [[ "$VM_DEBUG" -gt 1 ]]; then
		[[ -d hectorwatch-nuttx ]] || \
			git clone https://github.com/radupascale/hectorwatch-nuttx.git hectorwatch-nuttx
		(
			cd hectorwatch-nuttx
			git submodule init
			git submodule update
		)
	fi
}
echo "$(declare -f _install_user_config); _install_user_config" | su -c bash student

