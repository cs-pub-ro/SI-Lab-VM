#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# SI Lab VM configuration vars

LAB_VM_SRC=$(realpath $(sh_get_script_path)/..)

# Enable some features from the full_featured layer
VM_LEGACY_IFNAMES=1
VM_SYSTEM_TWEAKS=1
VM_INSTALL_TERM_TOOLS=1
VM_INSTALL_NET_TOOLS=1
VM_INSTALL_DEV_TOOLS=1
VM_INSTALL_HACKING_TOOLS=1
VM_INSTALL_DOCKER=0
VM_USER_TWEAKS=1
VM_USER_BASH_CONFIGS=1
VM_USER_ZSH_CONFIGS=1

# prepare package manager
@import 'debian/packages.sh'
pkg_init_update
