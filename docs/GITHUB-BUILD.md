# Build APK dengan GitHub Actions

Project ini sudah memiliki workflow otomatis sehingga Android SDK dan Build Tools tidak perlu dipasang di komputer lokal untuk proses build di GitHub.

## 1. Upload project ke GitHub

Buat repository baru di GitHub, lalu upload seluruh isi folder project ini.

## 2. Jalankan build

Buka tab **Actions** → pilih **Build Android APK** → **Run workflow**.

Workflow akan otomatis:

1. Menyiapkan JDK 17.
2. Menyiapkan Android SDK.
3. Memasang Android API 35 dan Build Tools 35.0.0.
4. Menyiapkan Gradle 8.11.1.
5. Menjalankan `:app:assembleDebug`.
6. Menyimpan APK sebagai GitHub Actions Artifact.

Setelah selesai, buka hasil workflow → bagian **Artifacts** → download `MANADO-P-TAMPA-BABELI-debug-apk`.

## Release

Workflow **Build Release APK** membuat `app-release.apk`. Untuk distribusi Play Store, gunakan signing key milik Anda sendiri. Jangan pernah memasukkan keystore atau password ke repository publik.

## Android Studio Windows

Anda tetap dapat membuka folder ini langsung di Android Studio. Android Studio akan meminta SDK yang diperlukan jika belum tersedia.
