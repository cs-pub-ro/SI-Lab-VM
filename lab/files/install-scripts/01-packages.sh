#!/bin/bash
# Installs debian packages

apt-get -y -qq update

apt-get -y install python3-pip pipx

# Embedded development tools
apt-get -y -qq install build-essential curl util-linux bridge-utils \
	unzip rsync findutils

apt-get -y -qq install --no-install-recommends \
	qemu-system-aarch64 qemu-user qemu-utils libvirt-daemon-system virtinst \
	bzr cvs  # required for some yocto pkgs

# NuttX deps
apt-get -y -qq install gettext libncursesw5-dev automake  \
	libtool pkg-config gperf genromfs libgmp-dev libmpc-dev libmpfr-dev libisl-dev \
	binutils-dev libelf-dev libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools \
	chrony libusb-dev libusb-1.0.0-dev python3-pip kconfig-frontends-nox

# Linux kernel dependencies
apt-get -y -qq install git fakeroot build-essential \
	libncurses5-dev libncurses-dev ncurses-dev xz-utils cpio \
	libssl-dev libelf-dev flex bc bison

# Debian packaging dependencies
apt-get -y install debhelper-compat dh-exec dh-python quilt
# Cross-build / bootstrapping tools
apt-get -y install crossbuild-essential-arm64 debootstrap binfmt-support qemu-user-static

# Yocto Linux Dependencies
apt-get -y install gawk wget git diffstat unzip texinfo gcc build-essential \
	chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
	iputils-ping python3-git python3-jinja2 python3-pylint-common python3-subunit \
	zstd liblz4-tool

# NFS & TFTP server
apt-get -y -qq install nfs-kernel-server tftpd-hpa
systemctl enable rpcbind
systemctl enable nfs-kernel-server.service

mkdir -p /srv/nfs
cat << EOF > /etc/exports
/srv/nfs  *(rw,sync,no_subtree_check,no_root_squash)
EOF

