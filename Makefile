## Makefile for SI lab VM
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk
include $(FRAMEWORK_DIR)/lib/inc_all.mk

# set default goals
DEFAULT_GOAL = labvm
INIT_GOAL = labvm
SUDO ?= sudo

# Fresh Ubuntu Server base VM
$(call vm_new_base_debian,base)
base-ver = 13

# SI Lab VM
labvm-ver = $(SI_LABVM_VERSION)
labvm-prefix = SI_$(labvm-ver)
# VM with ISC lab customizations
$(call vm_new_layer_full_featured,labvm)
labvm-name = $(labvm-prefix)
labvm-src-from = base
labvm-packer-args += -var 'disk_size=102400'
labvm-copy-scripts += $(abspath ./lab/scripts)/
labvm-extra-rules += $(vm_zerofree_rule)

# Export to VirtualBox / VMware
localvm-name = $(labvm-prefix)_Local
localvm-type = vm-combo
localvm-vmname = SI $(labvm-ver) VM
localvm-src-from = labvm
localvm-extra-rules += $(vm_zerofree_rule)

# Cloud-init image
$(call vm_new_layer_cloud,cloud)
cloud-name = $(labvm-prefix)_cloud
cloud-src-from = labvm
cloud-extra-rules += $(vm_zerofree_rule)

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms += base labvm localvm cloud

$(call vm_eval_all_rules)

