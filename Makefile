# Makefile for building the images

# user variables (override in local.mk)
TMP_DIR =
OS_INSTALL_ISO = 
DEBUG = 0
PAUSE = $(DEBUG)
DELETE = 
PACKER = packer
PACKER_ARGS = -on-error=abort -var "vm_pause=$(PAUSE)" -var "vm_debug=$(DEBUG)"
SSH = ssh
SSH_ARGS = 

# Fresh Ubuntu 22.04 base install
EXISTING_BASE_VM_PATH :=
BASE_VM_NAME = ubuntu_22_base
BASE_VM_SRC = base/
BASE_VM_OUT_DIR = $(TMP_DIR)/$(BASE_VM_NAME)
BASE_VM_OUT_IMAGE = $(BASE_VM_OUT_DIR)/$(BASE_VM_NAME).qcow2

# main lab VM image (from BASE_VM)
LAB_VM_NAME = SI_2022
LAB_VM_SRC = lab/
LAB_VM_OUT_DIR = $(TMP_DIR)/$(LAB_VM_NAME)
LAB_VM_OUT_IMAGE = $(LAB_VM_OUT_DIR)/$(LAB_VM_NAME).qcow2

# main lab VM image (from BASE_VM)
YOCTO_VM_NAME = SI_Yocto_2022
YOCTO_VM_SRC = yocto/
YOCTO_VM_OUT_DIR = $(TMP_DIR)/$(YOCTO_VM_NAME)
YOCTO_VM_OUT_IMAGE = $(YOCTO_VM_OUT_DIR)/$(YOCTO_VM_NAME).qcow2

# cloud-targeted image (from on LAB_VM)
CLOUD_VM_NAME = SI_2022_cloud
CLOUD_VM_SRC = cloud/
CLOUD_VM_OUT_IMAGE = $(TMP_DIR)/$(CLOUD_VM_NAME)/$(CLOUD_VM_NAME).qcow2

# include local customizations file
include local.mk

# macro for packer build script generation
# args:
_VM_SRC = $(strip $(1))
_VM_NAME = $(strip $(2))
_VM_SOURCE_IMAGE = $(strip $(3))
_VM_OUT_DIR = $(TMP_DIR)/$(_VM_NAME)
_PACKER_ARGS = $(PACKER_ARGS) \
			 -var "vm_name=$(_VM_NAME).qcow2" \
			 -var "source_image=$(_VM_SOURCE_IMAGE)" \
			 -var "output_directory=$(_VM_OUT_DIR)"
define packer_gen_build
	$(if $(DELETE),rm -rf "$(_VM_OUT_DIR)/",)
	cd "$(_VM_SRC)" && $(PACKER) build $(_PACKER_ARGS) "./"
endef

# Base image
ifeq ($(EXISTING_BASE_VM_PATH),)
base: $(BASE_VM_OUT_IMAGE)
$(BASE_VM_OUT_IMAGE): $(wildcard $(BASE_VM_SRC)/**) | $(TMP_DIR)/.empty
	$(call packer_gen_build, $(BASE_VM_SRC), \
		$(BASE_VM_NAME), $(OS_INSTALL_ISO))
base_clean:
	rm -rf "$(dir $(BASE_VM_OUT_IMAGE))/"
else
BASE_VM_OUT_IMAGE := $(EXISTING_BASE_VM_PATH)
endif

# SI Lab VM
labvm: $(LAB_VM_OUT_IMAGE)
$(LAB_VM_OUT_IMAGE): $(wildcard $(LAB_VM_SRC)/**) | $(BASE_VM_OUT_IMAGE)
	$(call packer_gen_build, $(LAB_VM_SRC), \
		$(LAB_VM_NAME), $(BASE_VM_OUT_IMAGE))

labvm_clean:
	rm -rf "$(dir $(LAB_VM_OUT_IMAGE))/"

# Quickly edit an already-generated Lab VM image
labvm_edit: PAUSE=1
labvm_edit: | $(LAB_VM_OUT_IMAGE)
	$(call packer_gen_build, $(LAB_VM_SRC), \
		$(LAB_VM_NAME)_tmp, $(LAB_VM_OUT_IMAGE))
# commits the edited image back to the original qcow2
LAB_VM_TMP_OUT_IMAGE = $(LAB_VM_OUT_DIR)_tmp/$(LAB_VM_NAME)_tmp.qcow2
labvm_commit:
	qemu-img commit "$(LAB_VM_TMP_OUT_IMAGE)"
	rm -rf "$(LAB_VM_OUT_DIR)_tmp/"

QEMU_NBD_DEV=nbd0
labvm_zerofree:
	sudo qemu-nbd -c "/dev/$(QEMU_NBD_DEV)" "$(LAB_VM_OUT_IMAGE)"
	sudo zerofree "/dev/$(QEMU_NBD_DEV)p2"; sudo qemu-nbd -d "/dev/$(QEMU_NBD_DEV)"

labvm_vmdk:
	qemu-img convert -O vmdk "$(LAB_VM_OUT_IMAGE)" "$(LAB_VM_OUT_DIR)/$(LAB_VM_NAME).vmdk"

# Yocto Build VM (beware: requires ~30GB of disk space available!)
yoctovm: $(YOCTO_VM_OUT_IMAGE)
$(YOCTO_VM_OUT_IMAGE): $(wildcard $(YOCTO_VM_SRC)/**) | $(LAB_VM_OUT_DIR)
	$(call packer_gen_build, $(YOCTO_VM_SRC), \
		$(YOCTO_VM_NAME), $(LAB_VM_OUT_IMAGE))
yoctovm_clean:
	rm -rf "$(dir $(YOCTO_VM_OUT_IMAGE))/"

# Quickly edit an already-generated Yocto VM image
yoctovm_edit: PAUSE=1
yoctovm_edit:
	$(call packer_gen_build, $(YOCTO_VM_SRC), \
		$(YOCTO_VM_NAME)_tmp, $(YOCTO_VM_OUT_IMAGE))
# commits the edited image back to the original qcow2
YOCTO_VM_TMP_OUT_IMAGE = $(YOCTO_VM_OUT_DIR)_tmp/$(YOCTO_VM_NAME)_tmp.qcow2
yoctovm_commit:
	qemu-img commit "$(YOCTO_VM_TMP_OUT_IMAGE)"
	rm -rf "$(YOCTO_VM_OUT_DIR)_tmp/"

yoctovm_zerofree:
	sudo qemu-nbd -c "/dev/$(QEMU_NBD_DEV)" "$(YOCTO_VM_OUT_IMAGE)"
	sudo zerofree "/dev/$(QEMU_NBD_DEV)p2"; sudo qemu-nbd -d "/dev/$(QEMU_NBD_DEV)"

yoctovm_vmdk:
	qemu-img convert -O vmdk "$(YOCTO_VM_OUT_IMAGE)" "$(YOCTO_VM_OUT_DIR)/$(YOCTO_VM_NAME).vmdk"

# ssh into a packer/qemu VM (note: only lab-vm-derived images support this)
ssh:
	$(SSH) $(SSH_ARGS) student@127.0.0.1 -p 20022

.PHONY: base labvm labvm_edit labvm_commit ssh

# Lab VM cloud-init variant (for EC2 / OpenStack)
cloudvm: $(CLOUD_VM_OUT_IMAGE)
$(CLOUD_VM_OUT_IMAGE): $(wildcard $(CLOUD_VM_SRC)/**) | $(LAB_VM_OUT_IMAGE)
	$(call packer_gen_build, $(CLOUD_VM_SRC), \
		$(CLOUD_VM_NAME), $(LAB_VM_OUT_IMAGE))
	qemu-img convert -O qcow2 "$(CLOUD_VM_OUT_IMAGE)" "$(CLOUD_VM_OUT_DIR)/$(CLOUD_VM_NAME)_full.qcow2"

# VM backing an already generated RL scripts image (saving time to edit it)
cloudvm_edit: | $(CLOUD_VM_OUT_IMAGE)
	$(call packer_gen_build, $(CLOUD_VM_SRC), \
		$(CLOUD_VM_NAME)_tmp, $(CLOUD_VM_OUT_IMAGE))

cloudvm_clean:
	rm -rf "$(TMP_DIR)/$(CLOUD_VM_NAME)/"

.PHONY: cloudvm cloudvm_edit cloudvm_clean

$(TMP_DIR)/.empty:
	mkdir -p "$(TMP_DIR)/"
	touch "$(TMP_DIR)/.empty"

print-%  : ; @echo $* = $($*)

