packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variables {
  vm_name = "si-lab-vm"
  vm_pause = 0
  vm_debug = 0
  source_image = "./path/to/ubuntu-22-base.qcow2"
  source_checksum = "none"
  output_directory = "/tmp/packer-out"
  ssh_username = "student"
  ssh_password = "student"
}

source "qemu" "si-lab-vm" {
  // VM Info:
  vm_name       = var.vm_name
  headless      = false

  // Virtual Hardware Specs
  memory         = 2048
  cpus           = 2
  disk_size      = 15000
  disk_interface = "virtio"
  net_device     = "virtio-net"
  // disk usage optimizations (unmap zeroes as free space)
  /* disk_discard   = "unmap" */
  /* disk_detect_zeroes = "unmap" */
  // skip_compaction = true
  
  // ISO & Output details
  iso_url           = var.source_image
  iso_checksum      = var.source_checksum
  disk_image        = true
  output_directory  = var.output_directory
  use_backing_file  = true

  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "30m"
  host_port_min     = 20022
  host_port_max     = 20022

  shutdown_command  = "sudo /sbin/shutdown -h now"
}

build {
  sources = ["sources.qemu.si-lab-vm"]

  provisioner "shell" {
    inline = [
      "rm -rf /home/student/install",
      "mkdir -p /home/student/install",
    ]
  }
  provisioner "file" {
    source = "files/"
    destination = "/home/student/install"
  }
  provisioner "shell" {
    inline = [
      "chmod +x /home/student/install/install.sh",
      "/home/student/install/install.sh"
    ]
    execute_command = "{{.Vars}} sudo -E -S bash -ex '{{.Path}}'"
  }

  provisioner "breakpoint" {
    disable = (var.vm_pause == 0)
    note    = "this is a breakpoint"
  }
}
