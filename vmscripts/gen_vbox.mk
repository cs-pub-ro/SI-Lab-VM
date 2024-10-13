# Makefile templates to generate VirtualBox VM project files

-vbox-build-dir = $(BUILD_DIR)/$(labvm-name)_vbox
# TODO: auto-generate machine UUID?
-vbox-machine-uuid = 0d312e4d-95cd-45f8-b8d0-f09d01286529

define vbox-template-prj=
<?xml version="1.0"?>
<!-- Generated by vm-framework -->
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.19-linux">
  <Machine uuid="{$(-vbox-machine-uuid)}" name="SI_2024" OSType="Ubuntu_64" snapshotFolder="Snapshots" lastStateChange="2024-10-13T10:53:32Z">
    <MediaRegistry>
      <HardDisks>
        <HardDisk uuid="{{{TEMPLATE_DISK_UUID}}}" location="$(labvm-name).vmdk" format="VMDK" type="Normal"/>
      </HardDisks>
    </MediaRegistry>
    <Hardware>
      <Memory RAMSize="4096"/>
      <HID Pointing="USBTablet"/>
      <Display controller="VMSVGA" VRAMSize="16"/>
      <Firmware/>
      <BIOS>
        <IOAPIC enabled="true"/>
        <SmbiosUuidLittleEndian enabled="true"/>
        <AutoSerialNumGen enabled="true"/>
      </BIOS>
      <USB>
        <Controllers>
          <Controller name="OHCI" type="OHCI"/>
          <Controller name="EHCI" type="EHCI"/>
        </Controllers>
      </USB>
      <Network>
        <Adapter slot="0" enabled="true" MACAddress="08002759A038" type="82540EM">
          <NAT localhost-reachable="true">
            <Forwarding name="SSH" proto="1" hostport="2022" guestport="22"/>
          </NAT>
        </Adapter>
      </Network>
      <AudioAdapter codec="AD1980" useDefault="true" driver="ALSA" enabled="false" enabledOut="true"/>
      <Clipboard/>
      <StorageControllers>
        <StorageController name="IDE" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="true">
          <AttachedDevice passthrough="false" type="DVD" hotpluggable="false" port="1" device="0"/>
        </StorageController>
        <StorageController name="SATA" type="AHCI" PortCount="1" useHostIOCache="false" Bootable="true" IDE0MasterEmulationPort="0" IDE0SlaveEmulationPort="1" IDE1MasterEmulationPort="2" IDE1SlaveEmulationPort="3">
          <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
            <Image uuid="{{{TEMPLATE_DISK_UUID}}}"/>
          </AttachedDevice>
        </StorageController>
      </StorageControllers>
      <RTC localOrUTC="UTC"/>
      <CPU count="2">
        <HardwareVirtExLargePages enabled="false"/>
        <PAE enabled="false"/>
        <LongMode enabled="true"/>
        <X2APIC enabled="true"/>
      </CPU>
    </Hardware>
  </Machine>
</VirtualBox>
endef

define vbox-template-rules=
.PHONY: release_vbox
release_vbox: $$(release-vmdk-file)
	rm -rf "$$(-vbox-build-dir)" && mkdir -p "$$(-vbox-build-dir)"
	echo "$$$$VBOX_PRJ_DATA" > "$$(-vbox-build-dir)/$$(labvm-name).vbox"
	cp -f "$$(release-vmdk-file)" "$$(-vbox-build-dir)/$$(labvm-name).vmdk"
	@echo "Assigning disk UUID..." && set -x && \
	UUID_RAW=$$$$(VBoxManage internalcommands sethduuid "$$(-vbox-build-dir)/$$(labvm-name).vmdk" 2>&1) && \
	UUID_EXTRACT=$$$$(echo -n "$$$$UUID_RAW" | \
				 grep -Po '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}') && \
	[[ -n "$$$$UUID_EXTRACT" ]] || exit 1 && \
	sed -i -e 's/{{TEMPLATE_DISK_UUID}}/'"$$$$UUID_EXTRACT"'/g' "$$(-vbox-build-dir)/$$(labvm-name).vbox"

export VBOX_PRJ_DATA:=$$(vbox-template-prj)

endef

