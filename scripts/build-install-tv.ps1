param(
    [string]$DeviceIp = "192.168.0.42",
    [string]$AdbPort = "5555",
    [string]$ApkPath = "build\app\outputs\flutter-apk\app-debug.apk",
    [switch]$Release
)

# Compila el APK y lo instala en el Android TV indicado.
# Uso:  .\build-install-tv.ps1 -DeviceIp 192.168.0.42
#       .\build-install-tv.ps1 -DeviceIp 192.168.0.42 -Release

$ErrorActionPreference = "Stop"

# Raíz del proyecto = carpeta padre de este script.
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

# Localiza adb (ruta canónica del entorno portátil, con fallback al PATH).
$Adb = "J:\AndroidSDK\platform-tools\adb.exe"
if (-not (Test-Path $Adb)) {
    $Adb = (Get-Command adb -ErrorAction SilentlyContinue).Source
    if (-not $Adb) {
        throw "No se encontró adb. Instala Android SDK platform-tools o añade adb al PATH."
    }
}

$Serial = "${DeviceIp}:${AdbPort}"

Write-Host "==> Proyecto: $ProjectRoot" -ForegroundColor Cyan
Write-Host "==> Compilando APK..." -ForegroundColor Cyan

if ($Release) {
    flutter build apk --release
    $ApkPath = "build\app\outputs\flutter-apk\app-release.apk"
} else {
    flutter build apk --debug
    $ApkPath = "build\app\outputs\flutter-apk\app-debug.apk"
}

if ($LASTEXITCODE -ne 0) {
    throw "La compilación falló (exit code $LASTEXITCODE)."
}
if (-not (Test-Path $ApkPath)) {
    throw "No se generó el APK en $ApkPath"
}

Write-Host "==> Conectando con $Serial..." -ForegroundColor Cyan
& $Adb connect $Serial | Out-Host

Write-Host "==> Instalando $ApkPath ..." -ForegroundColor Cyan
& $Adb -s $Serial install -r $ApkPath

if ($LASTEXITCODE -ne 0) {
    throw @"
La instalación falló. Comprueba:
  - La TV está encendida y en la misma red que el PC.
  - 'Depuración inalámbrica'/'ADB por red' activada en Opciones de desarrollador.
  - Si el dispositivo aparece 'unauthorized', acepta el diálogo en la TV.
  - El puerto no es el 5555: pásalo con -AdbPort <puerto>.
"@
}

Write-Host "==> Lanzando Kylora..." -ForegroundColor Cyan
& $Adb -s $Serial shell am start -n com.kylora.app/.MainActivity | Out-Host

Write-Host "==> Listo. APK instalado y app iniciada en $Serial." -ForegroundColor Green
