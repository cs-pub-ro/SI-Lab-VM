#!/bin/bash

function vm_wait_for_boot() {
	echo "Waiting for the VM to fully boot..."
	while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && \
		[ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do sleep 2; done
}

