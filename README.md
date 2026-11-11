# OpenCore EFI for Acer Nitro V 15 (ANV15-51 / ANV15-52)

[![macOS Version](https://img.shields.io/badge/macOS-Tahoe%2026.x%20%7C%20Sequoia%2015.x-blue.svg)](https://apple.com)
[![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8+-success.svg)](https://github.com/acidanthera/OpenCorePkg)
[![SMBIOS](https://img.shields.io/badge/SMBIOS-MacBookPro16%2C2-informational.svg)](https://apple.com)

OpenCore EFI configuration for the **Acer Nitro V 15 (ANV15-51 / ANV15-52)** running macOS Tahoe (26.x) and macOS Sequoia (15.x), featuring dual GPU acceleration, native AirDrop over Intel Wi-Fi, and custom NitroSense integration.

---

## 💻 Hardware Specifications

| Component | Specification | Status |
| :--- | :--- | :---: |
| **Processor** | Intel® Core™ i5-13420H (13th Gen, 4P + 4E Cores / 12 Threads) | ✅ Working |
| **iGPU** | Intel® Iris® Xe Graphics (Metal 3 & OpenGL accelerated) | ✅ Working |
| **dGPU** | NVIDIA® GeForce RTX™ 2050 / 3050 Laptop (NullMoth driver) | ✅ Working |
| **Memory** | 24 GB DDR5 5200 MHz RAM | ✅ Working |
| **Display** | 15.6" Full HD IPS (1920x1080) @ 100/144 Hz with smooth scaling | ✅ Working |
| **Display Out** | USB-C DisplayPort Alt-Mode & HDMI | ✅ Working |
| **Audio** | Realtek ALC245 (AppleALC layout 66/67) + Intel Display HDA | ✅ Working |
| **Microphone** | Internal Digital Mic array (LatSOFAudio) | ✅ Working |
| **Wi-Fi** | Intel® Wi-Fi 6 AX201/AX211 (ForbiddenItlwm with native AirDrop / AWDL) | ✅ Working |
| **Bluetooth** | Intel® Bluetooth 5.2 (IntelBluetoothFirmware + BTLEAdvFixup) | ✅ Working |
| **Ethernet** | Realtek RTL8111 PCI-E Gigabit LAN | ✅ Working |
| **Trackpad** | I2C HID Multi-touch Trackpad (VoodooI2C + polling patch) | ✅ Working |
| **Keyboard** | PS/2 Backlit Keyboard with brightness function keys | ✅ Working |
| **Thermal / Fans** | Acer NitroSense native daemon & menu bar app (RTX temp via RM 620.x RUSD) | ✅ Working |

---

## 🚀 Key Highlights & Custom Enhancements

1. **Native AirDrop on Intel Wi-Fi**:
   - Integrated [`ForbiddenItlwm`](https://github.com/retropineaple/ForbiddenItlwm) with AWDL (Apple Wireless Direct Link) on Channel 149 (80 MHz).
   - Patched [`BTLEAdvFixup`](https://github.com/retropineaple/ForbiddenItlwm/tree/main/BTLEAdvFixup) specifically supporting **macOS Tahoe 26.7.2 (`25G332`)** for seamless Bluetooth LE discovery.
   - AirDrop speeds up to ~22 MB/s without dropping regular Wi-Fi connection.

2. **Dual GPU Acceleration**:
   - Intel Iris Xe driven by `WhateverXe` with hardware hang recovery and HiDPI double buffering.
   - NVIDIA RTX dGPU accelerated via NullMoth `2.8.x` kernel extensions + `NGShim` Metal impostor.

3. **Accurate Processor Identification**:
   - `ProcessorType` is set to `1537` (`0x0601`) paired with `RestrictEvents` (`revcpu=1`, `revcpuname="13th Gen Intel Core i5-13420H"`) to ensure "About This Mac" displays the exact CPU model instead of "Unknown".

4. **Acer NitroSense macOS Integration**:
   - Custom macOS native port of NitroSense (`NitroSense.app`, `nitrod` daemon, `nitroctl` CLI).
   - Real-time CPU & RTX GPU temperatures, fan speed telemetry (RPM), power mode switching (Quiet / Default / Performance), and battery charge limiting.

---

## 🛠️ Installation & Post-Install Setup

### 1. Download & Clone
```bash
git clone https://github.com/farissyf30/EFI-Acer-Nitro-V15-anv15-51.git
```

### 2. Generate Your Own Serial Number (IMPORTANT ⚠️)
The `config.plist` in this repository has been sanitized for security reasons. Before booting, you **must generate your own unique SMBIOS identity**:

1. Download [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS).
2. Run GenSMBIOS and choose option `Generate SMBIOS`.
3. Enter model identifier: `MacBookPro16,2`.
4. Open `EFI/OC/config.plist` with [ProperTree](https://github.com/corpnewt/ProperTree) and paste the generated values under **`PlatformInfo -> Generic`**:
   - `MLB` (Board Serial)
   - `SystemSerialNumber` (Serial)
   - `SystemUUID` (SmUUID)
   - `ROM` (Use your actual Ethernet/Wi-Fi MAC address without colons, 12 hex characters)

### 3. Copy to EFI Partition
Copy the entire `EFI` folder to the EFI partition of your boot drive or USB flash drive.

### 4. Reset NVRAM
On your first boot with this EFI, select **`Reset NVRAM`** in the OpenCore boot picker menu (press `Space` if tools are hidden).

---

## 📁 Repository Structure

```
.
├── EFI/
│   ├── BOOT/
│   │   └── BOOTx64.efi
│   └── OC/
│       ├── ACPI/            # Patched SSDT tables (SSDT-EC, SSDT-PLUG, SSDT-NITRO, etc.)
│       ├── Drivers/         # OpenRuntime, HfsPlus, ResetNvramEntry
│       ├── Kexts/           # Tailored kernel extensions (ForbiddenItlwm, WhateverXe, etc.)
│       ├── Resources/       # OpenCanopy graphical boot assets
│       ├── Tools/           # UEFI shell & diagnostic utilities
│       ├── OpenCore.efi     # OpenCore binary
│       └── config.plist     # Pre-configured master plist (sanitized)
├── scripts/                 # Automation & post-install deployment scripts
└── acpi-dump/               # Native OEM ACPI tables dump for reference
```

---

## 🤝 Credits & Acknowledgements

- [Apple](https://apple.com) for macOS.
- [Acidanthera](https://github.com/acidanthera) for OpenCorePkg, Lilu, AppleALC, VirtualSMC, RestrictEvents, and BrcmPatchRAM.
- [OpenIntelWireless](https://github.com/OpenIntelWireless) for itlwm and IntelBluetoothFirmware.
- [retropineaple](https://github.com/retropineaple) for ForbiddenItlwm and BTLEAdvFixup AWDL AirDrop patches.
- [Thatisjigen](https://github.com/Thatisjigen) and the NullMoth driver team for macOS NVIDIA RTX graphics acceleration.
- [Dortania](https://dortania.github.io) for the comprehensive OpenCore guides.
