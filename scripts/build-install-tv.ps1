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
& $Adb disconnect $Serial 2>$null | Out-Null
$connectOutput = & $Adb connect $Serial 2>&1
$connectOutput | Out-Host

# `adb connect` puede responder "connected" y aun así dejar el dispositivo
# unauthorized/offline. Comprobamos el estado real antes de instalar.
$deviceLine = (& $Adb devices |
    Select-String -Pattern "^$([regex]::Escape($Serial))\s+" |
    Select-Object -First 1).Line
if (-not $deviceLine) {
    throw @"
No se pudo registrar el dispositivo $Serial en adb.

Comprueba:
  - La TV está encendida y en la misma red que el PC.
  - 'Depuración inalámbrica'/'ADB por red' activada en Opciones de desarrollador.
  - El puerto no es el 5555: pásalo con -AdbPort <puerto>.
"@
}

$state = ($deviceLine -split '\s+')[1]
if ($state -ne 'device') {
    $hint = switch ($state) {
        'unauthorized' { "Acepta el diálogo de depuración que aparece en la TV y vuelve a ejecutar el script." }
        'offline' { "El dispositivo está desconectado o no responde. Reinicia la depuración por red en la TV." }
        default { "Estado ADB: $state." }
    }
    throw "El dispositivo $Serial no está listo: $hint"
}

Write-Host "==> Instalando $ApkPath ..." -ForegroundColor Cyan
$installOutput = & $Adb -s $Serial install -r $ApkPath 2>&1
$installOutput | Out-Host
$installExit = $LASTEXITCODE

if ($installExit -ne 0 -or ($installOutput -match 'Failure|failed')) {
    throw @"
La instalación falló (exit code $installExit). Salida de adb:

$installOutput

Comprueba:
  - La TV está encendida y en la misma red que el PC.
  - 'Depuración inalámbrica'/'ADB por red' activada en Opciones de desarrollador.
  - Si el dispositivo aparece 'unauthorized', acepta el diálogo en la TV.
  - El puerto no es el 5555: pásalo con -AdbPort <puerto>.
  - Si el APK es grande y falla por espacio, usa -Release (APK más pequeño).
"@
}

Write-Host "==> Lanzando Kylora..." -ForegroundColor Cyan
& $Adb -s $Serial shell am start -n com.kylora.app/.MainActivity | Out-Host

Write-Host "==> Listo. APK instalado y app iniciada en $Serial." -ForegroundColor Green
