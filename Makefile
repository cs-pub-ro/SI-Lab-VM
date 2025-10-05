## Makefile for SI lab VM
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk
include $(FRAMEWORK_DIR)/lib/inc_all.mk

# set default goals
DEFAULT_GOAL = labvm
INIT_GOAL = labvm
SUDO ?= sudo
# debian uses partition #1 as rootfs
export ZEROFREE_PART_NUM=1

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
labvm-copy-scripts += $(abspath ./lab/scripts)/
labvm-extra-rules += $(vm_zerofree_rule)

$(call vm_new_layer_generic,bigvm)
bigvm-name = $(labvm-prefix)_Big
bigvm-src-from = labvm
bigvm-copy-scripts = $(abspath ./lab/scripts)/
bigvm-script-stage1 += bigvm-scripts.d
bigvm-packer-args += -var 'disk_size=102400'
bigvm-extra-rules += $(vm_zerofree_rule)

# Export to VirtualBox / VMware
localvm-name = $(labvm-prefix)_Local
localvm-type = vm-combo
localvm-vmname = SI $(labvm-ver) VM
localvm-src-from = bigvm

# Cloud-init image
$(call vm_new_layer_cloud,cloud)
cloud-name = $(labvm-prefix)_cloud
cloud-src-from = labvm
cloud-extra-rules += $(vm_zerofree_rule)

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms += base labvm bigvm localvm cloud

$(call vm_eval_all_rules)

