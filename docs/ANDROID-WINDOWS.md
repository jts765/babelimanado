# Setup Android SDK di Windows

## Opsi A — Android Studio

1. Instal Android Studio dari situs resmi Android Developers.
2. Saat setup, biarkan Android Studio memasang Android SDK.
3. Buka **Tools → SDK Manager**.
4. Pastikan Android SDK Platform 35 dan Android SDK Build-Tools 35.0.0 terpasang.
5. Buka project ini dan lakukan Gradle Sync.

## Opsi B — Command-line tools

Google juga menyediakan Android SDK Command-line Tools untuk Windows. Setelah memasangnya, gunakan `sdkmanager` untuk memasang:

- `platform-tools`
- `platforms;android-35`
- `build-tools;35.0.0`

Pastikan `JAVA_HOME` menunjuk ke JDK 17 atau lebih baru.

## Build lokal

Dari PowerShell pada root project:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\build-local-windows.ps1 -Variant Debug
```

Script akan menggunakan Gradle 8.11.1. Android SDK tetap harus tersedia di komputer untuk build Android.
