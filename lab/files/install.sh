#!/bin/bash
# VM provisioning script
# Note: must be run as root
set -e
export DEBIAN_FRONTEND=noninteractive

export SRC="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

source "$SRC/_utils.sh"

vm_wait_for_boot

chmod +x "$SRC/install-scripts/"*.sh

for script in "$SRC/install-scripts/"*.sh; do
	. "$script"
done

