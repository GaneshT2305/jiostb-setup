@echo off
set ADB=C:\Users\ganes\Desktop\sideload-jiostb\adb.exe
set STB=192.168.137.211:5555
set APKDIR=C:\Users\ganes\Desktop\jiotvplus_6010

echo === Install JioTV+ v6.0.10 (Android TV / Play Store build) ===
echo.

echo [1/3] Connecting to STB...
%ADB% connect %STB% >nul 2>&1
%ADB% -s %STB% shell echo OK >nul 2>&1 || (
    echo ERROR: Cannot reach STB. Run connect.bat first.
    exit /b 1
)
echo OK

echo [2/3] Verifying APK splits exist...
if not exist "%APKDIR%\base.apk" (
    echo ERROR: base.apk not found at %APKDIR%
    echo Extract the .apkm from APKMirror to that folder first.
    exit /b 1
)
if not exist "%APKDIR%\split_config.armeabi_v7a.apk" (
    echo ERROR: split_config.armeabi_v7a.apk not found
    exit /b 1
)
echo OK

echo [3/3] Installing JioTV+ v6.0.10 over existing version...
echo This may take 30-60 seconds...
%ADB% -s %STB% install-multiple -r ^
    "%APKDIR%\base.apk" ^
    "%APKDIR%\split_config.armeabi_v7a.apk" ^
    "%APKDIR%\split_config.xhdpi.apk" ^
    "%APKDIR%\split_config.en.apk"

if %ERRORLEVEL% == 0 (
    echo.
    echo Install successful!
    echo Launching JioTV+...
    %ADB% -s %STB% shell am start -n "com.jio.media.jiotvplus/com.jio.jioplay.jiotvplustwo.MainActivity"
) else (
    echo.
    echo Install failed. Try:
    echo   - Reconnect ADB: run connect.bat
    echo   - Check STB storage has enough space
)
