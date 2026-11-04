# Jio AirFiber STB — Modifications & Setup

ADB-based scripts to debloat, customize, and extend the Jio AirFiber Set-Top Box (Android TV).

## What This Covers

- Remove Jio bloatware and default launcher
- Set a custom home launcher (Monet)
- Enable Jio SSO for older JioTV+ builds
- Upgrade JioTV+ to the latest Android TV version
- Fix Kodi EPG issues

**No Docker, no server, no root required** — everything runs over ADB from a Windows PC.

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| Windows PC | Scripts are `.bat` files |
| ADB (platform-tools) | Download from [developer.android.com/tools/releases/platform-tools](https://developer.android.com/tools/releases/platform-tools) |
| curl | Built into Windows 10/11 |
| STB on same network as PC | ADB over WiFi — no USB cable |
| Developer Options on STB | Settings → About → click Build Number 7 times → enable ADB over Network |

---

## Quick Start

1. Edit `config.bat` — set your ADB path and STB IP
2. Run `connect.bat` — verify ADB connection
3. Run `setup.bat` — apply all STB modifications (run once)

---

## Configuration

Edit `config.bat` before running anything:

```batch
set ADB=C:\path\to\adb.exe        :: path to adb.exe from platform-tools
set STB=192.168.x.x:5555          :: your STB IP address
set APKDIR=C:\path\to\jiotvplus_6010  :: only needed for install-jiotvplus.bat
```

Find your STB IP: **STB Settings → Network → IP address**

---

## Scripts

### `connect.bat` — Connect ADB
Connects to STB over WiFi. Run this first and after every STB reboot.

```
connect.bat
```

---

### `setup.bat` — Full STB Modification (run once)

| Step | Action | Package |
|------|--------|---------|
| 1 | Enable Jio SSO STB | `com.media.jio.sso.stb` |
| 2 | Set Monet as home launcher | `com.klevico.monet` |
| 3 | Disable Jio data collector | `com.jio.adc.embedded` |
| 4 | Disable Jio Patchwall launcher | `com.jio.android.jiolauncher` |

```
setup.bat
```

Reboot the STB after for all changes to take effect.

---

### `install-jiotvplus.bat` — Upgrade JioTV+ to v6

Installs the Android TV / Play Store build (v6.0.10) over the STB-bundled v2.6.7.

**Why:** Jio stopped pushing v6 updates to the STB via JioStore. The Play Store build has a better UI and more features.

**Get the APK splits:**
1. Download `com.jio.media.jiotvplus_6.0.10` APKS from APKMirror
2. Rename `.apkm` → `.zip` and extract
3. Set `APKDIR` in `config.bat` to that folder

Required split files (STB is 32-bit ARM / `armeabi-v7a`):
- `base.apk`
- `split_config.armeabi_v7a.apk`
- `split_config.xhdpi.apk`
- `split_config.en.apk`

```
install-jiotvplus.bat
```

---

### `fix-kodi.bat` — Kodi EPG Fix

Clears Kodi data and restarts it when the EPG stops working.

```
fix-kodi.bat
```

Checks Kodi JSONRPC on port 8080. If no response, force-stops, clears data, and relaunches.

---

## Manual ADB Reference

```batch
set ADB=C:\path\to\adb.exe
set STB=192.168.x.x:5555

:: Connect
%ADB% connect %STB%

:: Launch JioTV+ v6
%ADB% -s %STB% shell am start -n "com.jio.media.jiotvplus/com.jio.jioplay.jiotvplustwo.MainActivity"

:: Check JioTV+ installed version
%ADB% -s %STB% shell dumpsys package com.jio.media.jiotvplus | findstr versionName

:: Enable or disable any package
%ADB% -s %STB% shell pm enable <package>
%ADB% -s %STB% shell pm disable-user --user 0 <package>

:: List all installed packages
%ADB% -s %STB% shell pm list packages

:: Reboot STB
%ADB% -s %STB% reboot

:: Screenshot (black = DRM content playing, that is normal)
%ADB% -s %STB% shell screencap -p /sdcard/screen.png
%ADB% -s %STB% pull /sdcard/screen.png .\screen.png

:: Live logcat
%ADB% -s %STB% logcat
```

## STB Hardware Notes

| Property | Value |
|----------|-------|
| CPU ABI | `armeabi-v7a` (32-bit ARM) |
| Product Type | `AirFiber-MU-Plan` |
| JioTV+ package | `com.jio.media.jiotvplus` |
| JioTV+ v6 activity | `com.jio.jioplay.jiotvplustwo.MainActivity` |

## Background

- **Patchwall** is the Jio STB home screen — it aggregates from JioTV+ and OTTs, it does not own content
- **JioStore** handles STB app updates (not OTA). Jio stopped publishing v6 to JioStore for STB
- **v6 vs v2**: Same package name, v6 is the Android TV build, v2.6.7 ships from factory on STB
- **HDCP/DRM**: Black screencaps during live TV are expected (secure surface for protected content)
