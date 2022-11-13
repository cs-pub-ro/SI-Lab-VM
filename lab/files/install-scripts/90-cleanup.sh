#!/bin/sh
# VM image cleanup script

apt-get -y purge libgl1-mesa-dri
apt-get -y --purge autoremove
apt-get -y autoclean

if [[ "$VM_DEBUG" -lt 1 ]]; then
	rm -rf /home/student/install*
	rm -f /home/student/.bash_history
	rm -f /root/.bash_history
fi
df -h

