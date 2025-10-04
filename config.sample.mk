# Sample VM build script config
# also check out framework/config.default.mk for all variables.

# Lab VM edition
SI_LABVM_VERSION = 2025

# Base .iso images dir
BASE_ISO_DIR ?= $(HOME)/Downloads/iso

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

