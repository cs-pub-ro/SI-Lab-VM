# Sample VM build script config
# also check out framework/config.default.mk for all variables.

# Lab VM edition
SI_LABVM_VERSION = 2024

# Ubuntu .iso image
BASE_VM_INSTALL_ISO = $(HOME)/Downloads/images/ubuntu-22.04.5-live-server-amd64.iso

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

