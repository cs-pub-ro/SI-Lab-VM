#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

[[ "$VM_INSTALL" != "null" ]] || exit 0

ESP_CROSSTOOL_DEST="/opt/xtensa/xtensa-esp-elf"
# skip task if already done
if [[ -d "$ESP_CROSSTOOL_DEST" ]]; then return 0; fi

# Download & install XTensa cross-compiler
ESP_CROSSTOOL_REL="https://github.com/espressif/crosstool-NG/releases/"
ESP_VER=$(fetch.sh --download=/tmp/nvim-linux.tar.gz "$ESP_CROSSTOOL_REL#prefix=esp-14." | head -1)
if [[ -z "$ESP_VER" ]]; then sh_log_fatal "Could not fetch ESP crosstool-NG version!"; fi
# remove `esp-` prefix from GH tag name
ESP_VER=${ESP_VER#esp-}
ESP_CROSSTOOL_URL="$ESP_CROSSTOOL_REL/download/esp-$ESP_VER/xtensa-esp-elf-$ESP_VER-x86_64-linux-gnu.tar.xz"

echo "Download URL: $ESP_CROSSTOOL_URL"
ESP_CROSSTOOL_ARCHIVE=/tmp/xtensa-esp-crosschain.tar.xz
wget -qO "$ESP_CROSSTOOL_ARCHIVE" "$ESP_CROSSTOOL_URL"

rm -rf "$ESP_CROSSTOOL_DEST" && mkdir -p "$ESP_CROSSTOOL_DEST"
tar xf "$ESP_CROSSTOOL_ARCHIVE" --strip-components=1 -C "$ESP_CROSSTOOL_DEST"
echo "export PATH=\$PATH:$ESP_CROSSTOOL_DEST/bin" > /etc/profile.d/xtensa.sh

