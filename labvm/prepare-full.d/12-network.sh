#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# VM network configuration

# Change hostname to si-lab-vm
LABVM_HOST="si-lab-vm"
if [[ "$(hostname)" != "$LABVM_HOST" ]]; then
	hostnamectl set-hostname $LABVM_HOST
	sed -i "s/^127.0.1.1\s.*/127.0.1.1       $LABVM_HOST/g"  /etc/hosts
fi


