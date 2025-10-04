#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

growpart /dev/vda 2 || true
resize2fs /dev/vda2 || true

