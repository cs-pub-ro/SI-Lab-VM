#!/bin/bash
# Installs debian packages

apt-get -y -qq update

apt-get -y install python3-pip pipx

# Embedded development tools
apt-get -y -qq install build-essential curl qemu qemu-system-aarch64 qemu-user \
	util-linux bridge-utils qemu-utils virtinst libvirt-daemon-system \
	virtinst unzip rsync findutils bzr cvs

# NuttX deps
apt-get -y -qq install gettext libncursesw5-dev automake  \
	libtool pkg-config gperf genromfs libgmp-dev libmpc-dev libmpfr-dev libisl-dev \
	binutils-dev libelf-dev libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools \
	chrony libusb-dev libusb-1.0.0-dev kconfig-frontends python3-pip

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

