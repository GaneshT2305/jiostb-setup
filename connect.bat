@echo off
set ADB=C:\Users\ganes\Desktop\sideload-jiostb\adb.exe
set STB=192.168.137.211:5555

echo Connecting to STB at %STB%...
%ADB% connect %STB%

%ADB% -s %STB% shell echo "ADB connection OK" && (
    echo Connected successfully.
) || (
    echo Failed to connect. Make sure:
    echo   1. STB is on the same network
    echo   2. Developer Options ^> ADB over Network is ON
    echo   3. STB IP is still %STB%
    exit /b 1
)
