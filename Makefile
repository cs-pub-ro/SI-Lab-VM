## Makefile for SI lab VM
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk

# set default goals
DEFAULT_GOAL = labvm
INIT_GOAL = labvm

SUDO = sudo

# Fresh Ubuntu Server base VM
ubuntu-ver = 22
basevm-name = ubuntu_$(ubuntu-ver)_base
basevm-packer-src = $(FRAMEWORK_DIR)/basevm
basevm-src-image = $(BASE_VM_INSTALL_ISO)
# VM destination file (automatically generated var.)
#basevm-dest-image = $(BUILD_DIR)/$(basevm-name)/$(basevm-name).qcow2

# SI Lab VM
labvm-ver = $(SI_LABVM_VERSION)
labvm-name = SI_$(labvm-ver)
labvm-packer-src = ./lab
labvm-src-from = basevm
define labvm-extra-rules=
.PHONY: labvm_compact
labvm-compact-guard := $(-vm-dest-dir)/.compacted
labvm_compact: $$(labvm-compact-guard)
$$(labvm-compact-guard): $(-vm-dest-timestamp)
	$(SUDO) "$(FRAMEWORK_DIR)/utils/zerofree.sh" "$$(labvm-dest-image)"
	touch "$$@" 

endef

release-ver = $(SI_LABVM_VERSION)
release-name = SI_$(labvm-ver)_Release
release-packer-src = ./lab
release-packer-args = -var 'disk_size=51200' -var 'vm_install=null'
release-src-from = labvm
release-src-deps = $(labvm-compact-guard)

include vmscripts/gen_vmware.mk
include vmscripts/gen_vbox.mk
release-extra-rules += $(vmware-template-rules) $(vbox-template-rules)

# SI Lab VM with full Yocto build (warning: it's HUGE!)
yocto-ver = $(SI_LABVM_VERSION)
yocto-name = SI_Yocto_$(labvm-ver)
yocto-packer-src = ./yocto
yocto-src-from = labvm

# Cloud-init image (based on labvm, see src-image)
cloudvm-name = ubuntu_$(ubuntu-ver)_cloud
cloudvm-packer-src = $(FRAMEWORK_DIR)/cloudvm
cloudvm-src-from = labvm

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms += basevm labvm release yocto cloudvm

$(call eval_common_rules)
$(call eval_all_vm_rules)

