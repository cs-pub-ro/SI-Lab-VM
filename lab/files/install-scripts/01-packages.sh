#!/bin/bash

apt-get -y -qq update

apt-get -y install python3-pip

# Embedded development tools
apt-get -y -qq install build-essential qemu qemu-system-aarch64 qemu-user \
	bridge-utils qemu-utils virtinst libvirt-daemon-system \
	gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf virtinst

# Linux kernel dependencies
apt-get -y -qq install git fakeroot build-essential \
	libncurses5-dev libncurses-dev ncurses-dev xz-utils \
	libssl-dev libelf-dev flex bison

# NFS & TFTP server
apt-get -y -qq install nfs-kernel-server tftpd-hpa
systemctl enable rpcbind
systemctl enable nfs-kernel-server.service

mkdir -p /srv/nfs
cat << EOF > /etc/exports
/srv/nfs  *(rw,sync,no_subtree_check,no_root_squash)
EOF

