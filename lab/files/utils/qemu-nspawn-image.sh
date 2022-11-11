#!/bin/bash
# Runs an image inside a systemd-nspawn container (using qemu-user-static)

IMAGE="$1"
MOUNTPOINT=/tmp/si-lab-rpi-mnt
QEMU_NBD_DEV=/dev/nbd0
QEMU_USER_STATIC_BINS=(/usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static)
NSPAWN_USER=root
NSPAWN_HOME=/root
NSPAWN_OPTS=(--capability=all)
NSPAWN_ENV=(
    TERM="$TERM" PS1='\u:\w\$ '
    DEBUG="$DEBUG" INSIDE_CHROOT=1
    PATH="/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/silo-distro/bin"
    USER="$NSPAWN_USER" HOME="$NSPAWN_HOME")
COMMAND=(/bin/bash)

sudo modprobe nbd max_part=8
sudo qemu-nbd -c "$QEMU_NBD_DEV" "$IMAGE"
sudo mkdir -p "$MOUNTPOINT"
sudo mount "${QEMU_NBD_DEV}p2" "$MOUNTPOINT"
sudo mount "${QEMU_NBD_DEV}p1" "$MOUNTPOINT/boot/firmware"

for bin_file in "${QEMU_USER_STATIC_BINS[@]}"; do
	sudo cp -f "$bin_file" "$MOUNTPOINT/usr/bin/"
done

sudo mkdir -p "$MOUNTPOINT"
sudo systemd-nspawn "${NSPAWN_OPTS[@]}" -D "$MOUNTPOINT" \
		env -i "${NSPAWN_ENV[@]}" "${COMMAND[@]}"

sudo umount "$MOUNTPOINT/boot/firmware"
sudo umount "$MOUNTPOINT"
sudo qemu-nbd -d "$QEMU_NBD_DEV"

