@echo off
call "%~dp0config.bat"

echo === JioAirFiber STB Initial Setup ===
echo.

echo [1/6] Connecting to STB...
%ADB% connect %STB% >nul 2>&1
%ADB% -s %STB% shell echo OK >nul 2>&1 || (
    echo ERROR: Cannot reach STB. Run connect.bat first.
    exit /b 1
)
echo OK

echo [2/6] Enabling Jio SSO STB (required for JioTV+ v2.x login)...
%ADB% -s %STB% shell pm enable com.media.jio.sso.stb
echo OK

echo [3/6] Permanently removing iWedia launcher (survives reboots)...
%ADB% -s %STB% shell pm uninstall --user 0 com.iwedia.ui.rjio.launcher.reliance
echo OK

echo [4/6] Setting Monet as default home launcher...
%ADB% -s %STB% shell cmd package set-home-activity com.klevico.monet/.HomeActivity
%ADB% -s %STB% shell am force-stop com.iwedia.ui.rjio.launcher.reliance
echo OK

echo [5/8] Disabling JioStore (stops auto app downloads and updates)...
%ADB% -s %STB% shell pm disable-user --user 0 com.jio.store
echo OK

echo [6/8] Disabling Jio ADC embedded (background data collector)...
%ADB% -s %STB% shell pm disable-user --user 0 com.jio.adc.embedded
echo OK

echo [7/8] Disabling Jio default launcher (Patchwall/JioEnv)...
%ADB% -s %STB% shell pm disable-user --user 0 com.jio.android.jiolauncher
echo OK

echo [8/8] Enabling dark mode permanently...
%ADB% -s %STB% shell cmd uimode night yes
%ADB% -s %STB% shell settings put secure ui_night_mode 2
echo OK

echo.
echo Setup complete! Reboot STB for changes to take full effect.
echo   %ADB% -s %STB% reboot
