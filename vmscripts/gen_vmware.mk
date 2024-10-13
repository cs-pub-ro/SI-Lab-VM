# Makefile templates to generate VMware project files

-vmware-build-dir = $(BUILD_DIR)/$(labvm-name)_vmware

define vmware-template-vmx=
#!/usr/bin/vmware
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "20"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
vmci0.present = "TRUE"
hpet0.present = "TRUE"
nvram = "SI_2024.nvram"
virtualHW.productCompatibility = "hosted"
gui.exitOnCLIHLT = "FALSE"
powerType.powerOff = "soft"
powerType.powerOn = "soft"
powerType.suspend = "soft"
powerType.reset = "soft"
displayName = "SI_2024"
guestOS = "ubuntu-64"
tools.syncTime = "FALSE"
sound.autoDetect = "TRUE"
sound.present = "FALSE"
sound.startConnected = "FALSE"
numvcpus = "2"
cpuid.coresPerSocket = "1"
vcpu.hotadd = "TRUE"
memsize = "4096"
mem.hotadd = "TRUE"
scsi0.virtualDev = "lsilogic"
scsi0.present = "TRUE"
scsi0:0.fileName = "SI_2024.vmdk"
scsi0:0.present = "TRUE"
sata0.present = "TRUE"
sata0:1.deviceType = "cdrom-raw"
sata0:1.fileName = "auto detect"
sata0:1.present = "FALSE"
usb.present = "TRUE"
usb.vbluetooth.startConnected = "FALSE"
usb:0.present = "TRUE"
usb:0.deviceType = "hid"
usb:0.port = "0"
usb:0.parent = "-1"
usb:1.speed = "2"
usb:1.present = "TRUE"
usb:1.deviceType = "hub"
usb:1.port = "1"
usb:1.parent = "-1"
svga.graphicsMemoryKB = "8388608"
ethernet0.connectionType = "nat"
ethernet0.addressType = "generated"
ethernet0.virtualDev = "e1000"
ethernet0.present = "TRUE"
floppy0.present = "FALSE"
vhv.enable = "TRUE"
ehci.present = "TRUE"
endef

define vmware-template-rules=
.PHONY: release_vmware
release_vmware: $$(release-vmdk-file)
	rm -rf "$$(-vmware-build-dir)" && mkdir -p "$$(-vmware-build-dir)"
	echo "$$$$VMWARE_VMX_DATA" > "$$(-vmware-build-dir)/$$(labvm-name).vmx"
	cp -f "$$(release-vmdk-file)" "$$(-vmware-build-dir)/$$(labvm-name).vmdk"

export VMWARE_VMX_DATA:=$$(vmware-template-vmx)

endef

