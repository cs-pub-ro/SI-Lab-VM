# Local build variables
# Copy this as 'local.mk'

# Path to required ISO images
OS_INSTALL_ISO = $(HOME)/Downloads/ubuntu-22.04.1-live-server-amd64.iso

# Set this if you want to use an existing base VM
#EXISTING_BASE_VM_PATH=$(HOME)/.cache/packer/ubuntu_22_base/ubuntu_22_base.qcow2

# Temporary and output directory to use.
# Make sure you have >10GB free space!
TMP_DIR=$(HOME)/.cache/packer

# SSH args (prevent host key warnings)
SSH_ARGS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

