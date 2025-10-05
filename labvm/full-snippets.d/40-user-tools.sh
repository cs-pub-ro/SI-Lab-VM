#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

[[ "$VM_INSTALL" != "null" ]] || exit 0

# give student user permissions to serial devices
usermod -a -G dialout student

# copy default files to /etc/skel
rsync -a --chown=root:root --chmod=755 "$LAB_VM_SRC/files/etc/skel/" "/etc/skel/"
# clone fzf
if [[ ! -d /etc/skel/.fzf/.git ]]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git /etc/skel/.fzf/
fi

# install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim*
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -f nvim-linux-x86_64.tar.gz

echo 'export PATH=/opt/nvim-linux-x86_64/bin:$PATH' > /etc/profile.d/30-nvim.sh

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# unfortunately, nvim plugins require nodejs + npm :| 
apt-get install -y nodejs npm

# install ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
dpkg -i ripgrep_14.1.1-1_amd64.deb

# install req. tools for the student user
function _install_user_config() {
	set -e
	pipx ensurepath
	pipx install esptool
	pipx install pyserial

	# copy skel over (since user was created previous to installing files)
	rsync -a --chmod=750 "/etc/skel/" "$HOME/"
	# install fzf
	yes | "$HOME/.fzf/install"

	# run zsh to install plugins
	zsh -i -c 'source ~/.zshrc; exit 0'

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
_exported_script="$(declare -p LAB_VM_SRC); $(declare -f _install_user_config)"
for u in student root; do
	echo "$_exported_script; _install_user_config" | su -c bash "$u"
	chsh -s /usr/bin/zsh "$u"
done

