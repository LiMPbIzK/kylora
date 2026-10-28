@echo off
REM Genera e instala el APK de Kylora en modo RELEASE.
REM No modifica build-install-tv.bat ni build-install-tv.ps1: reutiliza el .ps1
REM existente pasandole -Release.
REM
REM Uso:
REM   build-install-tv-release.bat
REM   build-install-tv-release.bat 192.168.0.42
REM   build-install-tv-release.bat 192.168.0.42 5555
REM
REM El APK resultante queda en:
REM   build\app\outputs\flutter-apk\app-release.apk
setlocal

set "IP=%~1"
if "%IP%"=="" set "IP=192.168.0.42"
set "PORT=%~2"
if "%PORT%"=="" set "PORT=5555"

echo.
echo === Kylora - compilacion RELEASE + instalacion en Android TV ===
echo === TV: %IP%:%PORT% ===
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-install-tv.ps1" -DeviceIp "%IP%" -AdbPort "%PORT%" -Release
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
  echo [OK] APK release compilado e instalado.
) else (
  echo [ERROR] El proceso termino con codigo %RC%.
)
echo.
pause
exit /b %RC%
