#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

pkg_install cloud-guest-utils

PART_NUM=1
if lsb_release -d | grep -i Ubuntu &>/dev/null; then
	# Ubuntu has a boot partition
	PART_NUM=2
fi

growpart /dev/vda "$PART_NUM" || true
resize2fs /dev/vda"$PART_NUM" || true

