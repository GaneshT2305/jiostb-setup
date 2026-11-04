@echo off
setlocal enabledelayedexpansion
call "%~dp0config.bat"

for /f "tokens=1 delims=:" %%i in ("%STB%") do set STB_IP=%%i

echo === India EPG Updater ===
echo Generating EPG from JioTV + Zee5...
python -I "%~dp0generate_epg.py"
if errorlevel 1 (
    echo ERROR: EPG generation failed
    pause
    exit /b 1
)

echo.
echo Pushing EPG to STB...
%ADB% -s %STB% push "%~dp0india_epg.xml" /sdcard/india_epg.xml
if errorlevel 1 (
    echo ERROR: Push failed. Is STB connected?
    echo Run: %ADB% connect %STB%
    pause
    exit /b 1
)

echo.
echo Done! EPG updated on STB.
echo.
echo In OTT Navigator, set EPG source to:
echo   file:///sdcard/india_epg.xml
echo.
pause
