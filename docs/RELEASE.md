# Release & Signing — حصن (Hesn)

## App icon
Source art lives in `assets/icon/` (`app_icon.png`, `app_icon_foreground.png`).
Regenerate platform icons after changing it:

```bash
flutter pub get
dart run flutter_launcher_icons
```

## Signing (Android)
Release builds are signed with an **upload keystore** that is **NOT** committed
(`android/app/upload-keystore.jks` and `android/key.properties` are gitignored).
`android/app/build.gradle.kts` loads `key.properties` when present and otherwise
falls back to debug signing (so CI and contributors can still build).

⚠️ **Back up the keystore and its password.** If you lose the upload key you
cannot publish updates under the same app. To create your own:

```bash
keytool -genkeypair -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# then create android/key.properties:
#   storePassword=...
#   keyPassword=...
#   keyAlias=upload
#   storeFile=upload-keystore.jks
```

## Build

```bash
source scripts/env.sh
flutter build apk --release          # signed APK
flutter build appbundle --release    # AAB for Google Play
```

iOS release requires macOS + Xcode and is not buildable on Linux.

## Store submission checklist
- [x] Mic usage strings (Android manifest + iOS `NSMicrophoneUsageDescription`)
- [x] Privacy policy (`docs/privacy-policy.md`) — host it and use the URL in the listing
- [ ] App-store listing (Arabic) + screenshots
- [ ] T045 — Arabic-speaker sign-off on `assets/azkar.json`
- [ ] T043 — on-device VAD tuning
