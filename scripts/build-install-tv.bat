@echo off
REM Lanzador del script de compilacion + instalacion en Android TV.
REM Uso:
REM   build-install-tv.bat
REM   build-install-tv.bat 192.168.0.42
REM   build-install-tv.bat 192.168.0.42 5555
REM   build-install-tv.bat 192.168.0.42 5555 -Release
setlocal

set "IP=%~1"
if "%IP%"=="" set "IP=192.168.0.42"
set "PORT=%~2"
if "%PORT%"=="" set "PORT=5555"

set "EXTRA="
if /I "%~3"=="-Release" set "EXTRA=-Release"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-install-tv.ps1" -DeviceIp "%IP%" -AdbPort "%PORT%" %EXTRA%
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
  echo [OK] Compilacion e instalacion completadas.
) else (
  echo [ERROR] El proceso termino con codigo %RC%.
)
echo.
pause
exit /b %RC%
