@echo off
:: ============================================================
:: Edit these values to match your setup before running scripts
:: ============================================================

:: Path to adb.exe on your PC
set ADB=C:\path\to\adb.exe

:: STB IP address (find in STB: Settings > Network > IP address)
:: Port is always 5555 for ADB over network
set STB=192.168.x.x:5555

:: Folder containing the extracted JioTV+ APK splits
set APKDIR=C:\path\to\jiotvplus_6010
