# JioAirFiber STB Setup

Scripts for setting up and maintaining the Jio AirFiber Set-Top Box (Android TV).

## Device Info

| Property | Value |
|----------|-------|
| ADB | `C:\Users\ganes\Desktop\sideload-jiostb\adb.exe` |
| STB IP | `192.168.137.211:5555` |
| CPU ABI | `armeabi-v7a` (32-bit ARM) |
| Product Type | `AirFiber-MU-Plan` |
| Home Launcher | Monet (`com.klevico.monet`) |

## Scripts

### `connect.bat`
Connects ADB over WiFi to the STB. Run this first before any other script.

```
connect.bat
```

**Prerequisites:**
- STB Developer Options → ADB over Network must be ON
- STB and PC on the same network

---

### `setup.bat`
Full initial setup after factory reset or new STB. Run once.

**What it does:**
1. Enables `com.media.jio.sso.stb` — Jio SSO STB app required for JioTV+ v2.x login (handles `app://open.sso.app` URI scheme)
2. Sets Monet as the default home launcher
3. Disables `com.jio.adc.embedded` — Jio background data collector
4. Disables `com.jio.android.jiolauncher` — Jio Patchwall launcher (Monet takes over)

```
setup.bat
```

---

### `install-jiotvplus.bat`
Installs JioTV+ v6.0.10 (Android TV / Play Store build) over the system-bundled v2.6.7.

**Prerequisites:**
- APK splits extracted from `.apkm` to `C:\Users\ganes\Desktop\jiotvplus_6010\`
- Required files:
  - `base.apk`
  - `split_config.armeabi_v7a.apk`
  - `split_config.xhdpi.apk`
  - `split_config.en.apk`

```
install-jiotvplus.bat
```

**Note:** After upgrade, main activity changes to `com.jio.jioplay.jiotvplustwo.MainActivity`.
The old `SplashActivity` no longer exists in v6.x.

**Network requirement:** JioTV+ v6 uses IP-based Jio network detection.
If STB is behind a PC hotspot instead of directly on AirFiber, it will show:
> "You are not on the Jio network. Switch to Jio network to continue watching."

Connect STB directly to the AirFiber router for playback.

---

### `fix-kodi.bat`
Fixes Kodi EPG by clearing data and restarting when Kodi stops responding.

```
fix-kodi.bat
```

Checks Kodi's JSONRPC endpoint at port 8080. If no response, clears app data and relaunches.

---

## Manual ADB Commands Reference

```batch
set ADB=C:\Users\ganes\Desktop\sideload-jiostb\adb.exe
set STB=192.168.137.211:5555

:: Connect
%ADB% connect %STB%

:: Launch JioTV+ v6
%ADB% -s %STB% shell am start -n "com.jio.media.jiotvplus/com.jio.jioplay.jiotvplustwo.MainActivity"

:: Check installed version
%ADB% -s %STB% shell dumpsys package com.jio.media.jiotvplus | findstr versionName

:: Reboot STB
%ADB% -s %STB% reboot

:: List all packages
%ADB% -s %STB% shell pm list packages

:: Take screenshot (note: DRM content = black screen, that's normal)
%ADB% -s %STB% shell screencap -p /sdcard/screen.png
%ADB% -s %STB% pull /sdcard/screen.png C:\Users\ganes\Desktop\screen.png

:: View live logs
%ADB% -s %STB% logcat
```

## Notes

- **Patchwall**: The Jio STB home screen aggregates content from JioTV+ and other OTTs. It does not own content directly — it's a launcher layer.
- **JioStore**: STB apps (including JioTV+) update via JioStore, not OTA. Jio stopped pushing v6 updates to the STB via JioStore, hence the manual install.
- **v6 vs v2**: Both versions use package `com.jio.media.jiotvplus`. v6 is the Android TV / Play Store build; v2.6.7 is the STB-specific build that ships from factory.
- **HDCP/DRM**: Screencaps during live TV show black — this is expected (secure surface for DRM content).
- **SSO note**: `com.media.jio.sso.stb` is only needed for v2.x login flow. v6 may handle auth differently.
