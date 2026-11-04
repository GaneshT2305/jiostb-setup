@echo off
call "%~dp0config.bat"

echo ============================================
echo  Jio AirFiber STB - Full Setup (run-all)
echo ============================================
echo.

:: ── Step 1: Connect ──────────────────────────
echo [1/4] Connecting to STB at %STB%...
%ADB% connect %STB% >nul 2>&1
%ADB% -s %STB% shell echo OK >nul 2>&1 || (
    echo ERROR: Cannot reach STB at %STB%
    echo - Run detect-stb.bat to auto-detect the IP
    echo - Or set STB= manually in config.bat
    exit /b 1
)
echo Connected.
echo.

:: ── Step 2: STB modifications ────────────────
echo [2/4] Applying STB modifications...
echo.
call "%~dp0setup.bat"
echo.

:: ── Step 3: JioTV+ v6 ────────────────────────
echo [3/4] JioTV+ v6 install...
if "%APKDIR%"=="C:\path\to\jiotvplus_6010" (
    echo   APKDIR not set in config.bat — skipping.
    echo   Set APKDIR to your extracted JioTV+ 6.0.10 folder and re-run.
) else if exist "%APKDIR%\base.apk" (
    call "%~dp0install-jiotvplus.bat"
) else (
    echo   base.apk not found at %APKDIR% — skipping.
)
echo.

:: ── Step 4: Aurora Store ─────────────────────
echo [4/4] Aurora Store install...
set AURORA_APK=
if exist "%~dp0..\sideload-jiostb\AuroraStore-4.8.4.apk" (
    set AURORA_APK=%~dp0..\sideload-jiostb\AuroraStore-4.8.4.apk
)
if defined AURORA_APK (
    echo   Installing from %AURORA_APK%
    %ADB% -s %STB% install "%AURORA_APK%" && (
        echo   Aurora Store installed.
        echo   Open it on TV: Settings ^> Interface ^> Enable TV Mode
    ) || echo   Install failed — try manually: adb install AuroraStore-4.8.4.apk
) else (
    echo   AuroraStore-4.8.4.apk not found in sideload-jiostb folder — skipping.
)
echo.

echo ============================================
echo  All done! Reboot STB to apply changes:
echo    %ADB% -s %STB% reboot
echo ============================================
