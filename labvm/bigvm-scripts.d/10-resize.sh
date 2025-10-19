#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

# prepare package manager
@import 'debian/packages.sh'
pkg_init_update

pkg_install cloud-guest-utils

PART_NUM=2

growpart /dev/vda "$PART_NUM" || true
resize2fs /dev/vda"$PART_NUM" || true

