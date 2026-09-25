param(
  [ValidateSet('Debug','Release')]
  [string]$Variant = 'Debug'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$gradleVersion = '8.11.1'
$gradleHome = Join-Path $env:USERPROFILE ".gradle\distributions\gradle-$gradleVersion"
$gradleExe = Join-Path $gradleHome "gradle-$gradleVersion\bin\gradle.bat"

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
  throw "Java 17+ is required. Install Android Studio or a JDK 17 distribution first."
}

if (-not (Test-Path $gradleExe)) {
  $cache = Join-Path $env:TEMP "gradle-$gradleVersion-bin.zip"
  $url = "https://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip"
  Write-Host "Downloading Gradle $gradleVersion..."
  Invoke-WebRequest -Uri $url -OutFile $cache
  New-Item -ItemType Directory -Force -Path $gradleHome | Out-Null
  Expand-Archive -Path $cache -DestinationPath $gradleHome -Force
}

Push-Location $root
try {
  & $gradleExe --no-daemon ":app:assemble$Variant"
  $apk = Join-Path $root "app\build\outputs\apk\$($Variant.ToLower())\app-$($Variant.ToLower()).apk"
  if (Test-Path $apk) {
    Write-Host "APK created: $apk"
  }
}
finally {
  Pop-Location
}
