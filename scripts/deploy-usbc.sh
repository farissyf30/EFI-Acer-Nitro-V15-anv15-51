#!/bin/bash
# deploy-usbc.sh — Copy USB-C changes to EFI partition
# Jalankan di Terminal: bash ~/Desktop/EFI-nvidia/deploy-usbc.sh

set -e
SRC="$HOME/Desktop/EFI-nvidia/OC"
SCRATCH="/tmp/efi_usbc_deploy"
EFI_DEV="/dev/disk1s1"
MOUNT_PT="$SCRATCH/efi"

echo "=== Deploy USB-C support ke EFI partition ==="
echo ""

# Mount EFI
mkdir -p "$MOUNT_PT"
echo "[1/5] Mounting EFI partition ($EFI_DEV)..."
sudo mount_msdos "$EFI_DEV" "$MOUNT_PT"
echo "      OK: $MOUNT_PT"

EFI_OC="$MOUNT_PT/EFI/OC"

echo "[2/5] Copying config.plist..."
sudo cp "$SRC/config.plist" "$EFI_OC/config.plist"

echo "[3/5] Copying ACPI tables..."
sudo cp "$SRC/ACPI/SSDT-USB-Reset.aml" "$EFI_OC/ACPI/SSDT-USB-Reset.aml"
sudo cp "$SRC/ACPI/SSDT-XOSI-ANV.aml"  "$EFI_OC/ACPI/SSDT-XOSI-ANV.aml"
sudo cp "$SRC/ACPI/SSDT-PNLF-ANV.aml"  "$EFI_OC/ACPI/SSDT-PNLF-ANV.aml" 2>/dev/null || echo "      (SSDT-PNLF-ANV.aml already there, skip)"

echo "[4/5] Copying kexts..."
# USBPorts.kext
if [ -d "$EFI_OC/Kexts/USBPorts.kext" ]; then
  sudo rm -rf "$EFI_OC/Kexts/USBPorts.kext"
fi
sudo cp -r "$SRC/Kexts/USBPorts.kext" "$EFI_OC/Kexts/USBPorts.kext"

# XHCI-unsupported.kext
if [ -d "$EFI_OC/Kexts/XHCI-unsupported.kext" ]; then
  sudo rm -rf "$EFI_OC/Kexts/XHCI-unsupported.kext"
fi
sudo cp -r "$SRC/Kexts/XHCI-unsupported.kext" "$EFI_OC/Kexts/XHCI-unsupported.kext"

echo "[5/5] Unmounting EFI..."
sudo umount "$MOUNT_PT"

echo ""
echo "=== SELESAI! ==="
echo ""
echo "Yang ditambahkan:"
echo "  ACPI: SSDT-USB-Reset.aml  (disable native RHUB agar macOS rebuild USB tree)"
echo "  ACPI: SSDT-XOSI-ANV.aml   (Windows compatibility shim untuk TXHC/USB-C)"
echo "  ACPI patch: _OSI -> XOSI  (intercept di DSDT)"
echo "  Kext: USBPorts.kext        (USB map: Type-C TXHC HS01/SS01 + semua port USB-A)"  
echo "  Kext: XHCI-unsupported.kext (force XHCI load untuk Raptor Lake PCH)"
echo ""
echo "Reboot sekarang dan colok kabel USB-C display."

