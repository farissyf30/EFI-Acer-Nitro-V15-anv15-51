#!/bin/bash
# install-smooth-display.sh
# Memperbaiki lag/stutter 100 Hz pada external display NVIDIA (NVRMFB + NVAccel)
# Jalankan: sudo bash ~/Desktop/EFI-nvidia/install-smooth-display.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Jalankan dengan sudo:" >&2
  echo "  sudo bash ~/Desktop/EFI-nvidia/install-smooth-display.sh" >&2
  exit 1
fi

OUT="/Users/faris/anv15-52-build/out"
EXT="/Library/Extensions"
KC="/Library/KernelCollections/AuxiliaryKernelExtensions.kc"
NEWKC="${KC}.anv-new"
KB="/System/Library/KernelCollections/BootKernelExtensions.kc"
KS="/System/Library/KernelCollections/SystemKernelExtensions.kc"
KERNEL="/System/Library/Kernels/kernel"

echo "== [1/4] Mengaktifkan tuning live sysctl untuk sesi saat ini..."
/usr/sbin/sysctl -w debug.nvaccel_iop_flip=1 debug.nvrmfb_flip_latch=2 debug.nvaccel_sv_take=2 debug.nvaccel_vm_pool=1 2>/dev/null || true

echo "== [2/4] Memasang binary NVRMFB dan NVAccel hasil optimasi (Hybrid 2.8.1 + Smooth 100 Hz + VRAM Pool)..."
rm -rf "$EXT/NMXAudio.kext"
for k in NVRMFB NVAccel; do
  if [ -d "$EXT/$k.kext/Contents/MacOS" ]; then
    cp -f "$OUT/$k.kext/Contents/MacOS/$k" "$EXT/$k.kext/Contents/MacOS/$k"
  else
    rm -rf "$EXT/$k.kext"
    /usr/bin/ditto --norsrc --noextattr "$OUT/$k.kext" "$EXT/$k.kext"
  fi
  /usr/bin/xattr -cr "$EXT/$k.kext" 2>/dev/null || true
  /usr/sbin/chown -R root:wheel "$EXT/$k.kext"
  /bin/chmod -R 755 "$EXT/$k.kext"
done

if [ -d /Library/NullMoth/kexts/26 ]; then
  if [ -d /Library/NullMoth/kexts/26/NVAccel.kext/Contents/MacOS ]; then
    cp -f "$OUT/NVAccel.kext/Contents/MacOS/NVAccel" /Library/NullMoth/kexts/26/NVAccel.kext/Contents/MacOS/NVAccel
  else
    rm -rf /Library/NullMoth/kexts/26/NVAccel.kext
    /usr/bin/ditto --norsrc --noextattr "$OUT/NVAccel.kext" /Library/NullMoth/kexts/26/NVAccel.kext
  fi
  /usr/bin/xattr -cr /Library/NullMoth/kexts/26/NVAccel.kext 2>/dev/null || true
  /usr/sbin/chown -R root:wheel /Library/NullMoth/kexts/26/NVAccel.kext
  /bin/chmod -R 755 /Library/NullMoth/kexts/26/NVAccel.kext
  (cd /Library/NullMoth/kexts/26 && /usr/bin/find NVAccel.kext -type f -exec /usr/bin/shasum -a 256 '{}' \;) > /Library/NullMoth/kexts/26/SHA256SUMS
fi

echo "== [3/4] Memperbarui /Library/NullMoth/bootguard.sh agar tuning aktif otomatis saat boot..."
if [ -f /Library/NullMoth/bootguard.sh ] && ! grep -q "nvrmfb_flip_latch=2" /Library/NullMoth/bootguard.sh; then
  sed -i '' 's/if pgrep -x WindowServer >\/dev\/null 2>&1; then/if pgrep -x WindowServer >\/dev\/null 2>\&1; then\
    sysctl -w debug.nvaccel_iop_flip=1 debug.nvrmfb_flip_latch=2 debug.nvaccel_sv_take=2 debug.nvaccel_vm_pool=1 >\/dev\/null 2>\&1 || true/' /Library/NullMoth/bootguard.sh
fi

echo "== [4/4] Membangun ulang AuxiliaryKernelExtensions.kc (kmutil, ~1 menit)..."
rm -f "$NEWKC"
/usr/bin/kmutil create -n aux --volume-root / --allow-missing-kdk --kernel "$KERNEL" -B "$KB" -S "$KS" --repository "$EXT" -A "$NEWKC" -z
/usr/bin/kmutil inspect -a x86_64 -A "$NEWKC" | grep -q "com.nullmoth.NVRMFB"
/usr/bin/kmutil inspect -a x86_64 -A "$NEWKC" | grep -q "com.nullmoth.NVAccel"
mv -f "$NEWKC" "$KC"

echo ""
echo "== SELESAI! =="
echo "1. Tuning live (flip_latch=2 & sv_take=2) sudah langsung aktif di sesi ini."
echo "2. Silakan REBOOT agar NVRMFB.kext & NVAccel.kext baru (fix BAR1 lock stall + flip cache) aktif penuh."

