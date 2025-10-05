# Embedded Systems lab virtual machine source code

This repository contains the Embedded Systems Lab VM generation scripts.
The process is automated using `qemu` and Packer (check the requirements below).

Requirements:
 - a modern Linux system;
 - basic build tools (make);
 - [Hashicorp's Packer](https://packer.io/);
 - [qemu+kvm](https://qemu.org/);

## Preparation

Download and save a [Debian 13 netinst](https://www.debian.org/CD/http-ftp/) iso image.

Copy `config.sample.mk` as `config.local.mk` and edit it to point to the directory
where the downloaded `.iso` files are. You might also want to change `TMP_DIR`
somewhere with 10GB free space and/or a faster drive (SSD recommended :P).

You might also want to ensure that packer and qemu are properly installed and
configured.

## Building the VM

The following Makefile goals are available (the build process is usually in this
order):

- `base`: builds a base Ubuntu/Debian install (required for the VM image);
- `labvm`: builds the Lab VM with all required scripts and config;
- `localvm`: builds the Local VM projects (VMWare & VirtualBox);
- `[*]_edit`: easily edit an already build Lab VM (uses the previous
  image as backing snapshot);
- `[*]_commit`: commits the edited VM back to its backing image;
- `[*]_clean`: removes the generated image(s);
- `ssh`: SSH-es into a running Packer VM;

If packer complains about the output file existing, you must either manually
delete the generated VM from inside `TMP_DIR`, or set the `DELETE=1` makefile
variable (but be careful):
```sh
make DELETE=1 labvm_edit
```

If you want to keep the install scripts at the end of the provisioning phase,
set the `DEBUG` variable. Also check out `PAUSE` (it pauses packer,
letting you inspect the VM inside qemu):
```sh
make PAUSE=1 DEBUG=1 labvm_edit
```
