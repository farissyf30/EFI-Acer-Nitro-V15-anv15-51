#!/bin/bash
set -e

SRC="$HOME/Desktop/EFI-nvidia/OC"
SCRATCH="/tmp/efi_airdrop_deploy"
MOUNT_PT="$SCRATCH/efi"

echo "=== Deploy AirDrop (ForbiddenItlwm + BTLEAdvFixup) ke EFI ==="
mkdir -p "$MOUNT_PT"

# Cek apakah partisi EFI sudah ter-mount di /Volumes/NO NAME
if [ -d "/Volumes/NO NAME/EFI/OC" ]; then
    EFI_OC="/Volumes/NO NAME/EFI/OC"
    echo "Partisi EFI aktif sudah ter-mount di /Volumes/NO NAME."
else
    # Jika belum ter-mount, mount partisi EFI
    for dev in /dev/disk1s1 /dev/disk0s1; do
        if mount_msdos "$dev" "$MOUNT_PT" 2>/dev/null; then
            if [ -d "$MOUNT_PT/EFI/OC" ]; then
                EFI_OC="$MOUNT_PT/EFI/OC"
                FOUND_DEV="$dev"
                echo "Ditemukan partisi EFI di $dev"
                break
            fi
            umount "$MOUNT_PT" 2>/dev/null || true
        fi
    done
fi

if [ -z "$FOUND_DEV" ]; then
    echo "ERROR: Tidak dapat menemukan partisi EFI dengan OpenCore!"
    exit 1
fi

EFI_OC="$MOUNT_PT/EFI/OC"

echo "[1/3] Menyalin config.plist terbaru..."
sudo cp "$SRC/config.plist" "$EFI_OC/config.plist"

echo "[2/3] Menyalin ForbiddenItlwm.kext..."
sudo rm -rf "$EFI_OC/Kexts/ForbiddenItlwm.kext"
sudo cp -R "$SRC/Kexts/ForbiddenItlwm.kext" "$EFI_OC/Kexts/ForbiddenItlwm.kext"

echo "[3/3] Menyalin BTLEAdvFixup.kext..."
sudo rm -rf "$EFI_OC/Kexts/BTLEAdvFixup.kext"
sudo cp -R "$SRC/Kexts/BTLEAdvFixup.kext" "$EFI_OC/Kexts/BTLEAdvFixup.kext"

sync
echo "Unmounting $FOUND_DEV..."
diskutil unmount "$MOUNT_PT" 2>/dev/null || sudo umount "$MOUNT_PT"
rm -rf "$SCRATCH" 2>/dev/null || true

echo ""
echo "=== SELESAI! ==="
echo "Konfigurasi AirDrop telah disinkronkan ke partisi EFI ($FOUND_DEV):"
echo " - ForbiddenItlwm.kext (replaces AirportItlwm for AWDL/AirDrop)"
echo " - BTLEAdvFixup.kext (with macOS 26.7.2 patches)"
echo " - IntelBTPatcher.kext dinonaktifkan (BTLEAdvFixup mengambil alih)"
echo " - boot-args AirDrop telah ditambahkan"
echo ""
echo "Langkah Terakhir:"
echo "Restart laptop Anda dan lakukan Reset NVRAM di menu OpenCore Picker."
