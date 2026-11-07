#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

[[ "$VM_INSTALL" != "null" ]] || exit 0
[[ "$XTENSA_INSTALL" == "1" ]] || exit 0

XTENSA_GCC_VER=${XTENSA_GCC_VER:-14}
XTENSA_ESP_FAMILY=${XTENSA_ESP_FAMILY:-esp}

ESP_DIRNAME="xtensa-$XTENSA_ESP_FAMILY-elf"
ESP_CROSSTOOL_DEST="/opt/xtensa/$ESP_DIRNAME"
# skip task if already done
if [[ -d "$ESP_CROSSTOOL_DEST" ]]; then return 0; fi

ESP_HOST_ARCH=x86_64
if uname -m | grep aarch64 >/dev/null; then
	ESP_HOST_ARCH=aarch64
fi

# Download & install XTensa cross-compiler
ESP_CROSSTOOL_REL="https://github.com/espressif/crosstool-NG/releases/"
ESP_VER=$(fetch.sh --download=/tmp/nvim-linux.tar.gz "$ESP_CROSSTOOL_REL#prefix=esp-$XTENSA_GCC_VER." | head -1)
if [[ -z "$ESP_VER" ]]; then sh_log_panic "Could not fetch ESP crosstool-NG version!"; fi
# remove `esp-` prefix from GH tag name
ESP_VER=${ESP_VER#esp-}

ESP_XC_ARCHIVE="$ESP_DIRNAME-$ESP_VER-$ESP_HOST_ARCH-linux-gnu.tar.xz"
ESP_CROSSTOOL_URL="$ESP_CROSSTOOL_REL/download/esp-$ESP_VER/$ESP_XC_ARCHIVE"

echo "Download URL: $ESP_CROSSTOOL_URL"
ESP_CROSSTOOL_ARCHIVE=/tmp/xtensa-esp-crosschain.tar.xz
wget -qO "$ESP_CROSSTOOL_ARCHIVE" "$ESP_CROSSTOOL_URL"

rm -rf "$ESP_CROSSTOOL_DEST" && mkdir -p "$ESP_CROSSTOOL_DEST"
tar xf "$ESP_CROSSTOOL_ARCHIVE" --strip-components=1 -C "$ESP_CROSSTOOL_DEST"
echo "export PATH=\$PATH:$ESP_CROSSTOOL_DEST/bin" > /etc/profile.d/xtensa.sh

