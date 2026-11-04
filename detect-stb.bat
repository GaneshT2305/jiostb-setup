@echo off
setlocal enabledelayedexpansion
call "%~dp0config.bat"

echo === Auto-detect STB IP ===
echo Scanning 192.168.137.x subnet (Windows hotspot range)...
echo.

:: Ping sweep to populate ARP cache quickly
for /l %%i in (1,1,254) do start /b ping -n 1 -w 100 192.168.137.%%i >nul 2>&1
timeout /t 3 /nobreak >nul

:: Check ARP table for live hosts, skip the Interface: header line
set FOUND_IP=
for /f "tokens=1" %%i in ('arp -a ^| findstr "192.168.137" ^| findstr /v "Interface"') do (
    if not defined FOUND_IP (
        echo Trying %%i...
        %ADB% connect %%i:5555 >nul 2>&1
        %ADB% -s %%i:5555 shell echo OK >"%TEMP%\adb_test.txt" 2>nul
        set /p ADB_RESULT=<"%TEMP%\adb_test.txt"
        if "!ADB_RESULT!"=="OK" set FOUND_IP=%%i
    )
)
del "%TEMP%\adb_test.txt" >nul 2>&1

if not defined FOUND_IP (
    echo.
    echo STB not found on 192.168.137.x subnet.
    echo - Make sure STB is connected to the laptop WiFi hotspot
    echo - Make sure stage1.sh has already been run to enable ADB
    exit /b 1
)

echo.
echo Found STB at %FOUND_IP%
echo Updating config.bat with STB=%FOUND_IP%:5555 ...

powershell -Command "(Get-Content '%~dp0config.bat') -replace 'set STB=.*', 'set STB=%FOUND_IP%:5555' | Set-Content '%~dp0config.bat'"

echo.
echo config.bat updated. Run connect.bat or run-all.bat to continue.
