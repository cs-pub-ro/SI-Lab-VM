#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# Installs debian packages

[[ "$VM_INSTALL" != "null" ]] || exit 0

# Embedded development tools
pkg_install build-essential curl util-linux bridge-utils unzip rsync findutils
pkg_install python3-pip pipx

pkg_install --no-install-recommends \
	qemu-system-aarch64 qemu-user qemu-utils libvirt-daemon-system virtinst \
	bzr cvs  # required for some yocto pkgs

# NuttX deps
pkg_install gettext libncursesw5-dev automake  \
	libtool pkg-config gperf genromfs libgmp-dev libmpc-dev libmpfr-dev libisl-dev \
	binutils-dev libelf-dev libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools \
	chrony libusb-dev libusb-1.0.0-dev python3-pip kconfig-frontends-nox

# Linux kernel dependencies
pkg_install git fakeroot build-essential \
	libncurses5-dev libncurses-dev ncurses-dev xz-utils cpio \
	libssl-dev libelf-dev flex bc bison

# Debian packaging dependencies
pkg_install debhelper-compat dh-exec dh-python quilt
# Cross-build / bootstrapping tools
pkg_install crossbuild-essential-arm64 debootstrap binfmt-support qemu-user-static

# Yocto Linux Dependencies
pkg_install gawk wget git diffstat unzip texinfo gcc build-essential \
	chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
	iputils-ping python3-git python3-jinja2 python3-pylint-common python3-subunit \
	zstd liblz4-tool

# NFS & TFTP server
pkg_install nfs-kernel-server tftpd-hpa
systemctl enable rpcbind
systemctl enable nfs-kernel-server.service

mkdir -p /srv/nfs
cat << EOF > /etc/exports
/srv/nfs  *(rw,sync,no_subtree_check,no_root_squash)
EOF

# install fetch.sh tool
FETCH_SCRIPT_URL="https://raw.githubusercontent.com/niflostancu/release-fetch-script/master/fetch.sh"
sudo wget -O /usr/local/bin/fetch.sh "$FETCH_SCRIPT_URL"
chmod +x /usr/local/bin/fetch.sh

