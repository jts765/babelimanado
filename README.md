# MANADO P TAMPA BABELI — Android Production Project

Android Studio project wrapping the supplied website as a production-oriented WebView app.

## Included
- Local website assets bundled under `app/src/main/assets/site/`
- Android WebView with JavaScript + DOM storage + cookies
- Android Back button navigation
- External links opened in the appropriate Android app/browser
- WhatsApp links opened externally
- HTML file upload chooser support
- Download/external file handling
- State restoration after configuration changes
- Hardware accelerated WebView rendering
- Release build configuration and ProGuard/R8 rules

## Build on Windows
1. Open this folder in Android Studio.
2. Allow Gradle Sync and install the requested Android SDK 35 if prompted.
3. Test with `Run` on an emulator/device.
4. For a test APK: **Build > Build APK(s)**.
5. For Play Store: **Build > Generate Signed App Bundle / APK**, create a release keystore and keep it backed up securely.

## Production signing
The project intentionally does not contain a private release keystore. Create your own signing key in Android Studio and use it for release builds. Never commit the keystore or passwords to source control.

## Automated GitHub build

This project includes GitHub Actions workflows in `.github/workflows/`.

- `Build Android APK` builds a downloadable debug APK.
- `Build Release APK` can be run manually to build the release variant.

See `docs/GITHUB-BUILD.md` for the exact steps.

## Windows command-line build

See `docs/ANDROID-WINDOWS.md` and run `scripts/build-local-windows.ps1` from PowerShell after Android SDK is installed.

## Release signing

Copy `keystore.properties.example` to `keystore.properties` and fill in your own keystore values for a signed local release. The real keystore and passwords are ignored by Git.
