@echo off
call "%~dp0config.bat"

echo === Kodi EPG Fix ===
echo.

echo [1/3] Connecting to STB...
%ADB% connect %STB% >nul 2>&1
%ADB% -s %STB% shell echo OK >nul 2>&1 || (
    echo ERROR: Cannot reach STB. Run connect.bat first.
    exit /b 1
)
echo OK

:: Extract IP from STB variable (strips :5555 port)
for /f "tokens=1 delims=:" %%i in ("%STB%") do set STB_IP=%%i

echo [2/3] Checking if Kodi is responding via JSONRPC...
curl -s --max-time 3 -X POST http://%STB_IP%:8080/jsonrpc ^
    -H "Content-Type: application/json" ^
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"JSONRPC.Ping\",\"id\":1}" ^
    | findstr /i "pong" >nul 2>&1

if %ERRORLEVEL% == 0 (
    echo Kodi is alive and responding - no fix needed.
    exit /b 0
)

echo Kodi not responding. Clearing data and restarting...

echo [3/3] Force-stop, clear Kodi data, then restart...
%ADB% -s %STB% shell am force-stop org.xbmc.kodi
timeout /t 2 /nobreak >nul
%ADB% -s %STB% shell pm clear org.xbmc.kodi
timeout /t 2 /nobreak >nul
%ADB% -s %STB% shell monkey -p org.xbmc.kodi -c android.intent.category.LEANBACK_LAUNCHER 1

echo.
echo Kodi restarted. EPG should reload on next launch.
