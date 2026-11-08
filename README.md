# JioAirFiber STB — Full Modification Guide

Complete guide to unlock, debloat, and set a permanent third-party launcher on the JioAirFiber Set-Top Box (Android TV).

**Tested on:** JMSD200A · Android 11 · armeabi-v7a

---

## Quick Start (AI-Assisted — Recommended)

The fastest way to run this setup is to let **Claude** (AI) do it for you. Claude can connect to your STB via ADB, run all the commands, and fix problems automatically — including edge cases this guide can't anticipate.

### Option A — Claude Code (CLI)

Install [Claude Code](https://claude.ai/code), then describe what you want:

```
I have a JioAirFiber STB at 192.168.137.42:5555. ADB is already enabled.
I want to:
1. Permanently remove the iWedia launcher so it doesn't come back after reboot
2. Set Monet (com.klevico.monet) as the permanent home launcher
3. Disable JioStore, Jio ADC, and OTA updates
4. Install JioTV+ v6 from C:\Downloads\jiotvplus_6010\
Run the ADB commands to do all of this.
```

Claude will run the commands, verify each step, and fix errors — no manual copy-pasting.

> **Why AI?** The iWedia launcher fix required understanding how Jio's modified `PackageManagerService` ignores `pm disable-user` state via `Relax SCAN_REQUIRE_KNOWN`, and how their SSO service resets `jio_launcher_type` on every boot. `pm uninstall --user 0` was discovered as the only persistent fix by diagnosing live logcat output during a session. Standard guides miss this.

### Option B — Claude.ai (Web)

Go to [claude.ai](https://claude.ai), paste this prompt:

```
I have a JioAirFiber Android TV set-top box (JMSD200A, Android 11).
ADB is enabled at 192.168.137.42:5555. adb.exe is at C:\path\to\adb.exe.

I want to permanently set Monet launcher as home and remove iWedia.
Give me exact ADB commands to run, in order, with explanation of why each one works.
```

Then run the commands it gives you.

---

## This is a Two-Phase Process

1. **Phase 1 — Enable ADB** (requires Docker + TR-069 exploit)
2. **Phase 2 — Post-ADB Setup** — set launcher, install apps, debloat

If ADB is already enabled on your STB, skip to [Phase 2](#phase-2--post-adb-setup).

---

## Phase 1 — Enable ADB on the STB

> ⚠️ Jio locks down the STB. Developer Options cannot be enabled the standard Android way (tapping Build Number). ADB must be unlocked via a TR-069/CWMP exploit.

### Network Setup — The Method That Works

```
Phone (non-Jio SIM) → Mobile Hotspot → Laptop → WiFi Hotspot → STB
```

**Why this works:**
- STB connects to the laptop's WiFi hotspot via DHCP
- Windows automatically assigns itself (`192.168.137.1`) as the STB's DNS server
- All STB DNS queries go to the laptop, where Technitium intercepts `acs.oss.jio.com`
- `stage1.sh` intercepts the STB's TR-069 connection at the laptop level
- Non-Jio SIM ensures the STB cannot reach Jio's real ACS server

**Steps:**
1. Turn on **mobile hotspot** on a phone with a **non-Jio SIM** (Airtel, Vi, BSNL etc.)
2. Connect your **laptop to that phone hotspot**
3. Turn on **Windows WiFi Hotspot** on the laptop (Settings → Mobile Hotspot)
4. Connect the **STB to the laptop's WiFi hotspot**
5. STB will get an IP in the `192.168.137.x` range — confirm with `ipconfig` on laptop

### PC Requirements

| Tool | Purpose | Download |
|------|---------|----------|
| **Docker Desktop** | Hosts local GenieACS/TLS backend | [docs.docker.com](https://docs.docker.com/desktop/setup/install/windows-install/) |
| **Python 3** | Runs proxy scripts (add to PATH during install) | [python.org](https://www.python.org/downloads/) |
| **Technitium DNS** | Intercepts STB's DNS queries on the laptop | [technitium.com](https://technitium.com/dns/) |
| **Git for Windows** | Bash terminal to run `.sh` scripts | [gitforwindows.org](https://gitforwindows.org/) |

### Run stage1.sh

Once STB is connected to the laptop hotspot, open Git Bash inside the `sideload-jiostb` folder:

```bash
cd ~/Desktop/sideload-jiostb
./stage1.sh
```

What you see when it's working:
- `[1/6] Checking prerequisites...` — Python, ADB binary, GenieACS NBI, TLS ports all show ✓
- `[2/6] Finding device in GenieACS...` — your STB serial number appears
- Enter your device number when prompted
- **Cold power cycle the STB** (unplug from wall, wait 5 seconds, plug back in)
- ADB permission prompt appears on the TV → check "Always allow" → OK

> Git Bash is required. These scripts will not run in Command Prompt or PowerShell.

### Full Toolkit

The complete `stage1.sh` process, Docker config, and Technitium setup is in:
👉 **https://github.com/ilikechocopies/sideload-jiostb**

Supported hardware: JMSC200Av2, JMSB200A, JHSC200 (JioOS 2.0)

---

## Phase 2 — Post-ADB Setup

### Edit config.bat

Open `config.bat` and fill in your values:

```batch
set ADB=C:\path\to\sideload-jiostb\adb.exe
set STB=192.168.x.x:5555
set APKDIR=C:\path\to\jiotvplus_6010   :: only for install-jiotvplus.bat
```

Auto-detect STB IP (scans `192.168.137.x` and writes into config.bat):

```
detect-stb.bat
```

### Run Everything at Once

```
run-all.bat
```

Runs: connect → setup → JioTV+ v6 (if APKDIR set) → Aurora Store install.

---

## Step 1 — Connect ADB

```
connect.bat
```

---

## Step 2 — Apply STB Modifications

```
setup.bat
```

| Step | Action | Command |
|------|--------|---------|
| 1 | Enable Jio SSO STB (login for JioTV+ v2.x) | `pm enable com.media.jio.sso.stb` |
| 2 | Enable Jio SSO STB (login for JioTV+ v2.x) | `pm enable com.media.jio.sso.stb` |
| 3 | **Permanently remove iWedia launcher** ⬅ key step | `pm uninstall --user 0 com.iwedia.ui.rjio.launcher.reliance` |
| 4 | Set Monet as HOME launcher | `cmd package set-home-activity com.klevico.monet/.HomeActivity` |
| 5 | Disable JioStore | `pm disable-user --user 0 com.jio.store` |
| 6 | Disable Jio background data collector | `pm disable-user --user 0 com.jio.adc.embedded` |
| 7 | Disable Jio Patchwall launcher | `pm disable-user --user 0 com.jio.android.jiolauncher` |
| 8 | Enable dark mode permanently | `cmd uimode night yes` |

Reboot STB after for changes to take full effect.

---

## ⚠️ Why `pm uninstall --user 0` and not `pm disable-user`

This was discovered through live ADB/logcat diagnosis. **`pm disable-user` does NOT survive a reboot on the JMSD200A firmware:**

| Method | Survives reboot on JMSD200A? |
|--------|------------------------------|
| `pm disable-user --user 0` | ❌ No |
| `settings put global jio_launcher_type third_party` | ❌ No |
| `cmd package set-home-activity` alone | ❌ No |
| **`pm uninstall --user 0`** | ✅ Yes — confirmed across 4+ cold reboots |

**Why disable-user fails:** Jio's modified `PackageManagerService` re-enables disabled packages on every boot via a flag called `Relax SCAN_REQUIRE_KNOWN`. Their Jio SSO service also resets `Settings.Global jio_launcher_type=home` on every boot.

**Why uninstall persists:** `pm uninstall --user 0` removes the package for user 0 in the per-user package database. Jio's firmware re-enables disabled packages but does not re-install uninstalled ones. The APK stays on the system partition; the user-0 install state does not.

**To revert** (restore iWedia):
```bash
adb shell cmd package install-existing com.iwedia.ui.rjio.launcher.reliance
```

---

## Step 3 — Upgrade JioTV+ to v6 (optional)

The STB ships with JioTV+ v2.6.7. The Android TV build (v6.0.10) has a better UI.

### Get the APK splits

1. Go to **APKMirror**, search for **JioTV+ 6.0.10**
2. Download the **APKS** bundle → rename `.apkm` → `.zip` → extract
3. Set `APKDIR` in `config.bat` to that extracted folder

Required splits (STB is 32-bit ARM / `armeabi-v7a`):
- `base.apk`
- `split_config.armeabi_v7a.apk`
- `split_config.xhdpi.apk`
- `split_config.en.apk`

```
install-jiotvplus.bat
```

---

## Step 4 — Install Aurora Store (optional)

Aurora Store is a Google Play client — access to all Play Store apps without a Google account.

```batch
adb -s %STB% install "C:\path\to\sideload-jiostb\AuroraStore-4.8.4.apk"
```

After install: open it → choose **Anonymous** → Settings → Interface → Enable TV Mode.

---

## ADB Quick Reference

```batch
:: Connect
adb connect 192.168.x.x:5555

:: Check current HOME launcher
adb -s %STB% shell dumpsys activity activities | findstr mResumedActivity

:: Is iWedia installed?
adb -s %STB% shell am start -n com.iwedia.ui.rjio.launcher.reliance/com.iwedia.ui.rjio.launcher.ui.intro.IntroActivity

:: Launch JioTV+ v6
adb -s %STB% shell am start -n "com.jio.media.jiotvplus/com.jio.jioplay.jiotvplustwo.MainActivity"

:: Check JioTV+ version
adb -s %STB% shell dumpsys package com.jio.media.jiotvplus | findstr versionName

:: Enable or disable any package
adb -s %STB% shell pm enable <package.name>
adb -s %STB% shell pm disable-user --user 0 <package.name>

:: Screenshot (black = DRM/live TV playing — normal)
adb -s %STB% shell screencap -p /sdcard/screen.png
adb -s %STB% pull /sdcard/screen.png .\screen.png

:: Live log (useful for diagnosing firmware behaviour)
adb -s %STB% logcat

:: Reboot STB
adb -s %STB% reboot
```

---

## Notes

| Topic | Detail |
|-------|--------|
| Developer Options | NOT accessible via standard Android method on Jio STB — use stage1.sh |
| iWedia launcher | Firmware package: `com.iwedia.ui.rjio.launcher.reliance` — use `pm uninstall --user 0`, not disable-user |
| Patchwall | Jio STB home screen — `com.jio.android.jiolauncher` — disable-user works for this one |
| JioStore | Handles app updates on STB (not OTA). Jio stopped publishing JioTV+ v6 via JioStore |
| v6 vs v2 | Same package name. v6 = Android TV / Play Store build. v2.6.7 = factory STB build |
| Black screencap | Expected during live TV — HDCP/DRM secure surface |
| SSO STB app | `com.media.jio.sso.stb` needed for v2.x login only. v6 handles auth internally |
| Package installer | Jio disabled the stock APK installer UI — always install via ADB |
| No JioStore on JMSD200A | iWedia cannot be accidentally reinstalled once uninstalled |
