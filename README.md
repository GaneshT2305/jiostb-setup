# Jio AirFiber STB — Full Modification Guide

Complete guide to debloat, customize, and extend the Jio AirFiber Set-Top Box (Android TV) using ADB from a Windows PC.

**No root required. No Docker. No server.**

---

## Overview

```
PC Setup → STB Setup → Connect ADB → Run Scripts → Done
```

---

## Step 1 — PC Requirements

Install these on your Windows PC before anything else.

### 1.1 ADB (Android Debug Bridge)

1. Download **Android Platform Tools** from:  
   https://developer.android.com/tools/releases/platform-tools
2. Extract the zip to a folder, e.g. `C:\platform-tools\`
3. Note the full path to `adb.exe` — you will add it to `config.bat`

### 1.2 curl

Already built into Windows 10 and Windows 11. No install needed.  
Verify: open Command Prompt and type `curl --version`

### 1.3 This Repo

Download or clone this repo to your PC:

```
git clone https://github.com/GaneshT2305/jiostb-setup
```

Or download as ZIP from GitHub and extract.

### 1.4 Edit config.bat

Open `config.bat` in Notepad and fill in your values:

```batch
set ADB=C:\platform-tools\adb.exe    :: path to your adb.exe
set STB=192.168.x.x:5555             :: your STB IP (find it in Step 2)
set APKDIR=C:\jiotvplus_6010         :: only needed if installing JioTV+ v6
```

---

## Step 2 — STB Setup (one-time)

Do these on the STB itself before connecting ADB.

### 2.1 Enable Developer Options

1. On STB: go to **Settings → About**
2. Find **Build Number** and click it **7 times**
3. Developer Options will now appear in Settings

### 2.2 Enable ADB over Network

1. Go to **Settings → Developer Options**
2. Turn on **ADB over Network** (or USB Debugging)
3. Note your STB IP: **Settings → Network → IP address**
4. Add it to `config.bat` as `set STB=<IP>:5555`

---

## Step 3 — Connect ADB

Run from your PC:

```
connect.bat
```

You should see: `Connected to 192.168.x.x:5555`

If it fails:
- Make sure PC and STB are on the same WiFi network
- Double-check the IP in `config.bat`
- Toggle ADB over Network off and on again on the STB

---

## Step 4 — Apply STB Modifications

Run once after a fresh STB or factory reset:

```
setup.bat
```

| What it does | Package |
|---|---|
| Enable Jio SSO STB (login for JioTV+ v2.x) | `com.media.jio.sso.stb` |
| Set Monet as home launcher | `com.klevico.monet` |
| Disable Jio background data collector | `com.jio.adc.embedded` |
| Disable Jio Patchwall launcher | `com.jio.android.jiolauncher` |

Reboot STB after:

```batch
:: Paste in Command Prompt after editing paths
C:\platform-tools\adb.exe -s 192.168.x.x:5555 reboot
```

---

## Step 5 — Upgrade JioTV+ to v6 (optional)

The STB ships with JioTV+ v2.6.7. The Android TV / Play Store build (v6) has a better UI and more features. Jio stopped publishing v6 updates to STB via JioStore, so this is a manual install.

### 5.1 Download APK splits

1. Go to **APKMirror** and download:  
   `JioTV+ 6.0.10` → choose **APKS** bundle (not APK)
2. Rename the downloaded `.apkm` file to `.zip`
3. Extract the zip — you will get several `.apk` files
4. Set `APKDIR` in `config.bat` to that extracted folder

Required files inside:
- `base.apk`
- `split_config.armeabi_v7a.apk` ← STB is 32-bit ARM, use this one
- `split_config.xhdpi.apk`
- `split_config.en.apk`

### 5.2 Install

```
install-jiotvplus.bat
```

Installation takes 30–60 seconds. JioTV+ will launch automatically when done.

---

## Step 6 — Fix Kodi EPG (when needed)

If Kodi's EPG/guide stops loading or Kodi becomes unresponsive:

```
fix-kodi.bat
```

This checks if Kodi is alive via its JSONRPC API. If not responding, it clears app data and restarts Kodi.

---

## ADB Quick Reference

```batch
:: Set these for your setup
set ADB=C:\platform-tools\adb.exe
set STB=192.168.x.x:5555

:: Connect
%ADB% connect %STB%

:: Launch JioTV+ v6
%ADB% -s %STB% shell am start -n "com.jio.media.jiotvplus/com.jio.jioplay.jiotvplustwo.MainActivity"

:: Check JioTV+ version
%ADB% -s %STB% shell dumpsys package com.jio.media.jiotvplus | findstr versionName

:: Enable or disable any package
%ADB% -s %STB% shell pm enable <package.name>
%ADB% -s %STB% shell pm disable-user --user 0 <package.name>

:: List all installed packages
%ADB% -s %STB% shell pm list packages

:: Reboot STB
%ADB% -s %STB% reboot

:: Screenshot (black = DRM/live TV playing — normal)
%ADB% -s %STB% shell screencap -p /sdcard/screen.png
%ADB% -s %STB% pull /sdcard/screen.png .\screen.png

:: Live log
%ADB% -s %STB% logcat
```

---

## Notes

| Topic | Detail |
|-------|--------|
| Root required? | No |
| Works over WiFi? | Yes — no USB cable needed |
| Patchwall | Jio STB home screen — aggregates from JioTV+ and OTTs, does not own content |
| JioStore | Handles STB app updates (not OTA). Jio stopped publishing JioTV+ v6 to JioStore for STB |
| v6 vs v2 | Same package name. v6 = Android TV / Play Store build. v2.6.7 = factory STB build |
| Black screencap | Expected during live TV — HDCP/DRM secure surface |
| SSO STB app | `com.media.jio.sso.stb` needed for v2.x login only. v6 handles auth internally |
