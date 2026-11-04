@echo off
set ADB=C:\Users\ganes\Desktop\sideload-jiostb\adb.exe
set STB=192.168.137.211:5555

echo === JioAirFiber STB Initial Setup ===
echo.

echo [1/5] Connecting to STB...
%ADB% connect %STB% >nul 2>&1
%ADB% -s %STB% shell echo OK >nul 2>&1 || (
    echo ERROR: Cannot reach STB. Run connect.bat first.
    exit /b 1
)
echo OK

echo [2/5] Enabling Jio SSO STB (required for JioTV+ v2.x login)...
%ADB% -s %STB% shell pm enable com.media.jio.sso.stb
echo OK

echo [3/5] Setting Monet as default home launcher...
%ADB% -s %STB% shell cmd package set-home-activity com.klevico.monet/.HomeActivity
echo OK

echo [4/5] Disabling Jio ADC embedded (background data collector)...
%ADB% -s %STB% shell pm disable-user --user 0 com.jio.adc.embedded
echo OK

echo [5/5] Disabling Jio default launcher (Patchwall/JioEnv)...
:: This keeps Monet as the only launcher
:: Comment out if you want to keep Jio launcher available
%ADB% -s %STB% shell pm disable-user --user 0 com.jio.android.jiolauncher
echo OK

echo.
echo Setup complete! Reboot STB for changes to take full effect.
echo   %ADB% -s %STB% reboot
