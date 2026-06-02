<div align="center">

# حصن · Hesn

**A hands-free morning & evening azkar app for Muslims — designed to be used while driving.**

أذكار الصباح والمساء — يقرأ الذكر، يستمع ليعرف أنك أنهيته، ثم ينتقل تلقائياً. بدون لمس، بدون إنترنت.

[![CI](https://github.com/drdeebtech/Hesn/actions/workflows/ci.yml/badge.svg)](https://github.com/drdeebtech/Hesn/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-3DDC84)
![Offline](https://img.shields.io/badge/offline-100%25-1E9E5A)
![License](https://img.shields.io/badge/license-MIT-blue)

</div>

---

## What it is

Hesn (حصن, "fortress" — from *Hisn al-Muslim*) guides you through the morning and
evening azkar phrase by phrase. It **reads each phrase aloud**, **listens** (audio
level only — no recording, no speech-to-text) to detect that you finished
reciting, then **advances to the next phrase**. Manual **تم** (Done) / **تجاوز**
(Skip) buttons are always there as a fallback.

It was built for one defining context: **using it while driving** — eyes-free,
hands-free, glanceable in under a second. Everything else follows from that.

## Features

- 🕌 **Morning & evening azkar** from Hisn al-Muslim, fully voweled (tashkīl), verbatim.
- 🚗 **Hands-free / driving mode** — speaks the repeat count, reads the phrase, advances by voice. No looking, no tapping.
- 🔊 **Read aloud (TTS)** with a strict **PLAY → STOP → LISTEN** loop so the mic never hears the app's own voice.
- 🎙️ **Voice-activity detection** (amplitude only) to advance when you've recited and paused — plus an 8–10s safety timeout that surfaces the Done button.
- 🔔 **Daily reminders** (morning + evening) that survive a reboot; tap one to jump straight into that session.
- 📿 **Per-day progress** that resets at midnight; **settings** for reminder times, sensitivity, and the hands-free toggle.
- 🌙 **Full Arabic, RTL**, bold high-contrast UI with automatic **dark mode** for night driving.
- 🔒 **Privacy by design** — no recording, no speech-to-text, **no network**. Nothing leaves your device.

## Privacy

> نستمع فقط لنعرف أنك أنهيت الذكر، لا نسجّل صوتك ولا نحوّله إلى نص ولا يخرج من جهازك.

We only listen to know you finished the dhikr. **We do not record your voice, do
not convert it to text, and nothing leaves your device.** The microphone is active
only during a session. The app makes no network calls — there's an automated test
that fails the build if a network dependency is ever added. Full policy:
[`docs/privacy-policy.md`](docs/privacy-policy.md).

## Tech stack

Flutter (Material 3) · Dart · `setState` (no state-management library) ·
`flutter_tts` · `record` (amplitude VAD) · `flutter_local_notifications` +
`timezone` · `shared_preferences` · `permission_handler`. Azkar content ships as
a bundled `assets/azkar.json`. No backend, no accounts.

## Getting started

> The dev toolchain isn't on the default PATH — load it first.

```bash
git clone https://github.com/drdeebtech/Hesn.git
cd Hesn
source scripts/env.sh        # Flutter + OpenJDK 17 + Android SDK
flutter pub get

flutter run                  # on a connected device/emulator
flutter build apk --debug    # build an installable APK (no device needed)
```

iOS requires macOS + Xcode (`flutter build ios`). See
[`docs/RELEASE.md`](docs/RELEASE.md) for signing and store steps.

## Testing

```bash
source scripts/env.sh
flutter analyze              # static analysis
flutter test                 # full suite
```

Tests guard the non-negotiables: the **PLAY→STOP→LISTEN** ordering, **one advance
per phrase**, the **no-network** guarantee, and that `assets/azkar.json` matches
the source text **verbatim**.

## Project structure

```
lib/
├── models/        AzkarItem/List, AppSettings, DailyProgress
├── data/          azkar_repository (loads assets/azkar.json)
├── services/      tts · vad · notifications · storage · permissions · cue (behind interfaces)
├── session/       session_controller (ANNOUNCE→PLAY→STOP→LISTEN), vad_detector, announcer
├── screens/       home · session (the hero) · settings
├── widgets/       azkar_text_view · repeat_counter · progress_badge
└── theme/         app_theme (light + dark)
assets/azkar.json  Hisn al-Muslim morning + evening, voweled, with Qur'an flags
specs/             Spec-driven development docs (constitution, spec, plan, tasks)
```

## How it was built

Hesn was developed with **[Spec Kit](https://github.com/github/spec-kit)**
spec-driven development. The project **constitution**
(`.specify/memory/constitution.md`) encodes the non-negotiable rules — sacred-text
integrity, PLAY→STOP→LISTEN, privacy, one-advance-per-phrase — and every feature
flows through specify → clarify → plan → tasks → implement. The full spec lives
under [`specs/001-azkar-session/`](specs/001-azkar-session/).

## Status

Feature-complete and green (analyze clean, tests passing, signed release APK
builds). Before a public release, two human/device gates remain: on-device VAD
tuning, and a competent Arabic speaker's sign-off on `assets/azkar.json`.

## License

MIT — see [`LICENSE`](LICENSE). Azkar text is from Hisn al-Muslim (حصن المسلم).
