#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# Zephyr RTOS prerequisites (ESP32-S3)

[[ "$VM_INSTALL" != "null" ]] || return 0
[[ "$ZEPHYR_INSTALL" == "1" ]] || return 0

# Zephyr getting-started system dependencies (Ubuntu)
pkg_install cmake ninja-build ccache gperf diffutils cpio socat xxd \
    libelf-dev libffi-dev libusb-1.0-0-dev dfu-util \
    python3-venv python3-setuptools python3-pip python3-yaml python3-pytest \
    screen

# Zephyr SDK - minimal install: SDK scaffold (cmake + host tools) plus only
# the Xtensa (ESP32-S3) GNU toolchain required by the lab's boards.
ZEPHYR_SDK_DEST=/opt/zephyr-sdk
if [[ ! -f "$ZEPHYR_SDK_DEST/sdk_version" ]]; then
	SDK_JSON=$(curl -s "https://api.github.com/repos/zephyrproject-rtos/sdk-ng/releases/latest")
	SDK_MIN_URL=$(echo "$SDK_JSON" | grep -oE 'https://[^"]+_linux-x86_64_minimal\.tar\.xz' | head -1)
	SDK_XTENSA_URL=$(echo "$SDK_JSON" | grep -oE 'https://[^"]+_linux-x86_64_xtensa-espressif_esp32s3_zephyr-elf\.tar\.xz' | head -1)
	if [[ -z "$SDK_MIN_URL" || -z "$SDK_XTENSA_URL" ]]; then
		sh_log_panic "Could not resolve Zephyr SDK download URLs!"
	fi
	sh_log_info "Downloading Zephyr SDK (minimal + xtensa-esp32s3): $SDK_MIN_URL $SDK_XTENSA_URL"
	wget -qO /tmp/zephyr-sdk-minimal.tar.xz "$SDK_MIN_URL"
	mkdir -p "$ZEPHYR_SDK_DEST"
	tar xf /tmp/zephyr-sdk-minimal.tar.xz -C "$ZEPHYR_SDK_DEST" --strip-components=1
	rm -f /tmp/zephyr-sdk-minimal.tar.xz
	wget -qO /tmp/zephyr-sdk-xtensa.tar.xz "$SDK_XTENSA_URL"
	# Zephyr's cmake looks for toolchains under $ZEPHYR_SDK_INSTALL_DIR/gnu/<prefix>
	mkdir -p "$ZEPHYR_SDK_DEST/gnu"
	tar xf /tmp/zephyr-sdk-xtensa.tar.xz -C "$ZEPHYR_SDK_DEST/gnu/"
	rm -f /tmp/zephyr-sdk-xtensa.tar.xz
fi
# make the SDK discoverable by Zephyr/west in every shell
cat > /etc/profile.d/35-zephyr.sh << 'EOF'
export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
EOF

# west (Zephyr meta-tool), students will use it from their own venv
pipx install --global west

