#!/bin/bash
set -e

SRC="$HOME/Desktop/EFI-nvidia/OC"
SCRATCH="/tmp/efi_cpu_deploy"
MOUNT_PT="$SCRATCH/efi"

echo "=== Deploy Perbaikan ProcessorType ke EFI ==="
mkdir -p "$MOUNT_PT"

FOUND_DEV=""
for dev in /dev/disk1s1 /dev/disk0s1 /dev/disk1s3; do
    if sudo mount_msdos "$dev" "$MOUNT_PT" 2>/dev/null; then
        if [ -f "$MOUNT_PT/EFI/OC/OpenCore.efi" ] || [ -f "$MOUNT_PT/EFI/OC/config.plist" ]; then
            FOUND_DEV="$dev"
            echo "Ditemukan partisi EFI aktif di $dev"
            break
        fi
        sudo umount "$MOUNT_PT" 2>/dev/null || true
    fi
done

if [ -z "$FOUND_DEV" ]; then
    echo "ERROR: Tidak dapat menemukan partisi EFI dengan OpenCore!"
    exit 1
fi

echo "Menyalin config.plist ke $MOUNT_PT/EFI/OC/config.plist..."
sudo cp "$SRC/config.plist" "$MOUNT_PT/EFI/OC/config.plist"
sync

echo "Unmounting $FOUND_DEV..."
diskutil unmount "$MOUNT_PT" || sudo umount "$MOUNT_PT"
rm -rf "$SCRATCH" 2>/dev/null || true

echo ""
echo "=== SELESAI! ==="
echo "config.plist pada partisi EFI ($FOUND_DEV) telah diperbarui:"
echo " - ProcessorType: 1537 (0x0601 / Apple Core i5)"
echo " - revcpuname: 13th Gen Intel Core i5-13420H"
echo " - revpatch: sbvmm,cpuname"
echo ""
echo "Langkah Terakhir:"
echo "Restart laptop Anda, lalu pada menu OpenCore pilih 'Reset NVRAM'."

