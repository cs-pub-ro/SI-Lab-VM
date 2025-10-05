#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# Installs debian packages

[[ "$VM_INSTALL" != "null" ]] || exit 0

# Essential tools
pkg_install build-essential sudo util-linux unzip findutils curl wget \
		rsync git iputils-ping bridge-utils
pkg_install python3-pip pipx

# installed by 32-dev-tools.sh (full-feature layer), use Debian's crossbuild
pkg_remove gcc-multilib
pkg_install crossbuild-essential-arm64 

# virtualization / containerization utils
pkg_install --no-install-recommends qemu-system-aarch64 qemu-user qemu-utils \
	binfmt-support qemu-user-static libvirt-daemon-system virtinst \
	systemd-container

# debian packaging tools
pkg_install fakeroot devscripts debhelper-compat dh-exec dh-python quilt \
	debootstrap debianutils

# Linux kernel dependencies
pkg_install  flex bc bison xz-utils cpio kmod libssl-dev \
	libncurses-dev libncurses5-dev libelf-dev device-tree-compiler
# newer kernels require libssl-dev for target architecture (arm64)
dpkg --add-architecture armhf && dpkg --add-architecture arm64
apt-get update && apt-get -y install libssl-dev:arm64 libssl-dev:armhf

# NuttX deps
pkg_install gettext libncursesw5-dev automake  \
	libtool pkg-config gperf genromfs libgmp-dev libmpc-dev libmpfr-dev libisl-dev \
	binutils-dev libelf-dev libexpat-dev picocom u-boot-tools \
	chrony libusb-dev libusb-1.0.0-dev kconfig-frontends-nox

# Buildroot / Yocto Linux Dependencies
pkg_install gawk wget diffstat texinfo chrpath socat cpio python3-pexpect \
	python3-git python3-jinja2 python3-pylint-common python3-subunit \
	zstd lz4 bzr cvs

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
wget -O /usr/local/bin/fetch.sh "$FETCH_SCRIPT_URL"
chmod +x /usr/local/bin/fetch.sh

