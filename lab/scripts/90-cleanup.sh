#!/bin/sh
# VM image cleanup script

set -e
export DEBIAN_FRONTEND=noninteractive

apt-get -y autoremove
apt-get -y clean

dd if=/dev/zero of=/.zerofill || true
rm -rf /.zerofill

df -h

