#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

[[ "$VM_INSTALL" != "null" ]] || exit 0

# give student user permissions to serial devices
usermod -a -G dialout student

# install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim*
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -f nvim-linux-x86_64.tar.gz
# make nvim available in non-login shells (e.g. `su`) as well
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

echo 'export PATH=/opt/nvim-linux-x86_64/bin:$PATH' > /etc/profile.d/30-nvim.sh

# unfortunately, nvim plugins require nodejs + npm :| 
pkg_install nodejs npm

# install ripgrep
GH_ARCH=x86_64
if uname -m | grep x86_64 >/dev/null; then
	curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
	dpkg -i ripgrep_*_amd64.deb
	rm -f ripgrep*.deb
elif uname -m | grep aarch64 >/dev/null; then
	curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz
	tar -xf ripgrep-*-aarch64-*.tar.gz --strip-components=1 -C /usr/local/bin --wildcards '*/rg'
	rm -f ripgrep-*-aarch64-*.tar.gz
fi

# install esptool globally (+ pyserial for optional CLI)
pipx install --global esptool
pipx install --global pyserial

# udev rules: grant the student dialout access to all Espressif USB devices
# (USB Serial/JTAG, ROM-mode bootloader) for flashing without sudo
cat > /etc/udev/rules.d/80-esp32.rules << 'EOF'
SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", MODE="0660", GROUP="dialout"
EOF
udevadm control --reload-rules

# install labvm-dotfiles + req. tools for the student user
function _install_user_config() {
	set -e

	# install labvm-dotfiles (bash/zsh/nvim/tmux/fzf configs)
	# `fetch` component skipped: fetch.sh is installed system-wide
	DOTFILES_ARGS=(-fetch)
	"$LAB_VM_SRC/files/labvm-dotfiles/install.sh" "${DOTFILES_ARGS[@]}"

	# ensure pipx path
	pipx ensurepath
	zsh -c 'pipx ensurepath'

	# set git identities
	git config --global user.email "$USER@si-lab-vm.local"
	git config --global user.name "SI ${USER}"
}
_exported_script="$(declare -p LAB_VM_SRC); $(declare -f _install_user_config)"
for u in student root; do
	echo "$_exported_script; _install_user_config" | su -c bash "$u"
	chsh -s /usr/bin/zsh "$u"
done

