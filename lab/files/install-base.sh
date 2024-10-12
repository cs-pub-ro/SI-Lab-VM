#!/bin/bash
# Boot/networking tweaks (requiring reboot)
# Everything should run as root

set -eo pipefail
export SRC="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

source "$SRC/_utils.sh"
export DEBIAN_FRONTEND=noninteractive

vm_wait_for_boot

if [[ "$VM_NOINSTALL" == "1" ]]; then
	exit 0
fi

# generate locales
locale-gen "en_US.UTF-8"
localectl set-locale LANG=en_US.UTF-8

export DEBIAN_FRONTEND=noninteractive
# remove some useless packages like snapd and stock docker
apt-get purge snapd docker.io || true
apt-get update
apt-get -y upgrade
# remove older kernels
apt-get -y --purge autoremove
# virtualization drivers & base networking
apt-get install --no-install-recommends -y open-vm-tools iproute2

# Change hostname to si-lab-vm
if [[ "$(hostname)" != "si-lab-vm" ]]; then
	hostnamectl set-hostname si-lab-vm
	sed -i "s/^127.0.1.1\s.*/127.0.1.1       si-lab-vm/g"  /etc/hosts
fi

# setup an empty network interfaces
rm -f /etc/netplan/*.yaml
rsync -ai --chown="root:root" --chmod="755" "$SRC/etc/netplan/" /etc/netplan/

if grep -q " biosdevname=0 " /proc/cmdline; then
	exit 0
fi

echo "blacklist floppy" > /etc/modprobe.d/blacklist-floppy.conf
dpkg-reconfigure initramfs-tools

# Use old interface names (ethX) + disable qxl modeset (spice is buggy)
GRUB_CMDLINE_LINUX="quiet net.ifnames=0 biosdevname=0"
# disable cgroupv1 (docker might still use it... or smth')
GRUB_CMDLINE_LINUX+=" cgroup_no_v1=all"
sed -i "s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE_LINUX\"/g" /etc/default/grub
update-grub

# reboot
systemctl stop sshd.service
nohup shutdown -r now < /dev/null > /dev/null 2>&1 &
sleep 1
exit 0
