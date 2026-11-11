#!/bin/bash
# install-nitrosense.sh
# Install NitroSense daemon + app + SMCNvidiaGPU ke sistem
# Jalankan: sudo bash ~/Desktop/EFI-nvidia/install-nitrosense.sh

set -e

REPO="/Users/faris/.gemini/antigravity/brain/d6bdd687-7a57-4d5f-baef-be793cf83d34/scratch/acer-nitro-anv15-52-macos"
BUILD="$HOME/anv15-52-build/out"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Jalankan dengan sudo:"
    echo "  sudo bash ~/Desktop/EFI-nvidia/install-nitrosense.sh"
    exit 1
fi

echo "=== Install NitroSense + SMCNvidiaGPU ==="
echo ""

# --- NitroSense daemon (nitrod) ---
echo "[1/5] Installing nitrod daemon..."
mkdir -p "/Library/Application Support/NitroSense"
cp "$BUILD/nitrosense/nitrod"   "/Library/Application Support/NitroSense/nitrod"
cp "$BUILD/nitrosense/nitroctl" "/Library/Application Support/NitroSense/nitroctl"
chmod +x "/Library/Application Support/NitroSense/nitrod"
chmod +x "/Library/Application Support/NitroSense/nitroctl"
echo "      OK: /Library/Application Support/NitroSense/"

# --- LaunchDaemon plist ---
echo "[2/5] Installing LaunchDaemon..."
cat > /Library/LaunchDaemons/com.nitrosense.nitrod.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.nitrosense.nitrod</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/Application Support/NitroSense/nitrod</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ThrottleInterval</key>
    <integer>10</integer>
    <key>StandardErrorPath</key>
    <string>/var/log/nitrod.log</string>
</dict>
</plist>
PLIST
chmod 644 /Library/LaunchDaemons/com.nitrosense.nitrod.plist
echo "      OK: /Library/LaunchDaemons/com.nitrosense.nitrod.plist"

# --- NitroSense.app ---
echo "[3/5] Installing NitroSense.app..."
killall NitroSense 2>/dev/null || true
if [ -d "/Applications/NitroSense.app" ]; then
    rm -rf "/Applications/NitroSense.app"
fi
cp -r "$BUILD/nitrosense/NitroSense.app" "/Applications/NitroSense.app"
echo "      OK: /Applications/NitroSense.app"

# --- Load daemon sekarang (tidak perlu reboot untuk daemon) ---
echo "[4/5] Loading nitrod daemon..."
launchctl bootout system/com.nitrosense.nitrod 2>/dev/null || true
launchctl bootstrap system /Library/LaunchDaemons/com.nitrosense.nitrod.plist
sleep 2
STATUS=$(launchctl print system/com.nitrosense.nitrod 2>&1 | grep "state" || echo "unknown")
echo "      Daemon status: $STATUS"

# --- Verify ---
echo "[5/5] Verifying..."
echo ""
echo "=== HASIL ==="
echo ""

if launchctl print system/com.nitrosense.nitrod 2>/dev/null | grep -q "state = running"; then
    echo "  ✅ nitrod daemon: RUNNING"
else
    echo "  ⚠️  nitrod daemon: NOT running (akan start setelah reboot + NitroEC.kext aktif)"
fi

if [ -f "/Applications/NitroSense.app/Contents/MacOS/NitroSense" ]; then
    echo "  ✅ NitroSense.app: INSTALLED di /Applications/"
fi

if [ -f "/Library/Application Support/NitroSense/nitroctl" ]; then
    echo "  ✅ nitroctl: INSTALLED"
fi

echo ""
echo "=== LANGKAH SELANJUTNYA ==="
echo ""
echo "1. Copy EFI ke EFI partition (config.plist + NitroEC.kext + SSDT-NITRO.aml)"
echo "   - config.plist      → EFI/OC/"
echo "   - SSDT-NITRO.aml    → EFI/OC/ACPI/"
echo "   - NitroEC.kext/     → EFI/OC/Kexts/"
echo ""
echo "2. Reboot"
echo ""
echo "3. Setelah reboot, buka NitroSense.app dari /Applications/"
echo "   - Kalau NitroEC.kext loaded, app akan bisa kontrol:"
echo "     * Fan speed"
echo "     * Power mode (Silent/Balanced/Performance)"
echo "     * Battery charge limit (80%)"
echo ""
echo "4. Verifikasi SMCNvidiaGPU (sudah ON di EFI):"
echo "   kextstat | grep SMCNvidia"
echo "   → Buka iStatMenus / HWMonitor → GPU temperature NVIDIA muncul"
echo ""
echo "Done!"

