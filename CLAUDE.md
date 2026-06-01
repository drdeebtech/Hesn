# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

This repository holds the spec/plan for an Azkar (أذكار) mobile app and an installed dev harness. `plan.md` is the locked product spec; `spec.md`/`plan.md`/`tasks.md` under `specs/` (Spec Kit) drive implementation. Treat `plan.md` decisions as constraints, not suggestions.

The dev harness is **installed but not on the default PATH**. Load it in any shell first:

```bash
source scripts/env.sh   # adds Flutter, OpenJDK 17, Android SDK to PATH
```

This wires: Flutter 3.44 stable (`~/flutter`), OpenJDK 17 (Homebrew), Android SDK (`~/Android/Sdk`, platforms 34+36, build-tools 34+36, platform-tools). `flutter doctor` is green for the Android toolchain. Web/Linux-desktop targets are intentionally not set up (mobile-only app). iOS needs macOS and cannot be built here.

## What the app is

A morning/evening azkar app: it reads each phrase aloud via TTS, listens (audio-level VAD only — **no** speech-to-text, **no** pronunciation check) to detect the user finished reciting, then auto-advances. Manual "تم" (Done) and "تجاوز" (Skip) buttons are always present. Fully Arabic, RTL. No backend, no login, no cloud — all storage is local.

## Non-negotiable constraints (from plan.md)

These are the rules most likely to be violated by well-intentioned changes:

- **PLAY → STOP → LISTEN must be strictly sequential.** Never open the mic while TTS is playing, or the app hears its own voice and auto-advances. This is the single most important runtime invariant.
- **One advance per phrase.** The repeat count is shown on screen but the user counts repeats themselves — do not auto-advance once per repeat.
- **Repeat counts and azkar text come from Hisn al-Muslim (حصن المسلم) verbatim.** Repeat counts are a religious ruling — never improvise or "fix" them. Text must stay fully voweled (with tashkīl) and unaltered.
- **Arabic strings are literal app content, not translatable instructions.** UI labels and azkar text are kept in Arabic on purpose.
- **`type: "quran"` items are Qur'anic verses** (Ayat al-Kursi, al-Ikhlas, al-Falaq, al-Nas, last verses of al-Baqarah). Handle with care; never treat as editable text.
- **Privacy is a hard guarantee:** no audio recording, no speech-to-text, nothing leaves the device, mic active only during a session. Do not add any dependency or code path that breaks this.

Permanently out of scope (do not add): `speech_to_text`, text normalization, similarity/pronunciation matching, login, backend, AI, cloud sync, automatic prayer-time calculation.

## Planned stack (not yet installed)

Per `plan.md` §5: `flutter_tts` (audio out), `record` (audio-level VAD), `flutter_local_notifications` (reminders), `shared_preferences` (settings + progress), `permission_handler` (mic), `intl`. State management is deliberately plain `setState` — do not introduce a state-management library.

Commands (after `source scripts/env.sh`):

```bash
flutter pub get                         # resolve dependencies
flutter analyze                         # lint / static analysis
flutter test                            # run all tests
flutter test test/<file>_test.dart      # run a single test file
flutter build apk --debug               # build Android APK (no device/emulator needed)
```

## Tooling note

This environment has `.claude-flow/` (claude-flow orchestration) configured. The user's global instructions describe swarm/agent workflows; the project `CLAUDE.md` referenced there lives at `/home/drdeeb/CLAUDE.md`, not in this repo.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
