# Quickstart: Hesn (Guided Azkar Session)

## Prerequisites

The dev harness is installed but not on the default PATH. In every shell, first:

```bash
cd ~/Hesn
source scripts/env.sh        # Flutter 3.44, OpenJDK 17, Android SDK
flutter doctor               # Android toolchain should be green
```

## One-time scaffolding

The platform folders (`android/`, `ios/`) are generated once; app code lives in `lib/`:

```bash
flutter create . --org com.hesn --project-name hesn --platforms android,ios
flutter pub get
```

> `flutter create .` over an existing `pubspec.yaml`/`lib/` preserves them and only adds the
> platform scaffolding. After it runs, re-confirm `pubspec.yaml` still lists the locked deps.

## Run / build (Android)

```bash
flutter run                       # on a connected device/emulator
flutter build apk --debug         # build APK without a device (works headless)
```

iOS requires macOS + Xcode and cannot be built in this environment.

## Verify quality gates (must pass before release)

```bash
flutter analyze                   # static analysis clean
flutter test                      # all tests green
flutter test test/session/session_controller_test.dart   # the PLAY->STOP->LISTEN guard
```

## What "working" looks like (maps to spec Success Criteria)

1. Launch → Home shows أذكار الصباح / أذكار المساء with today's status (SC-004, SC-005).
2. Start a list → first phrase is shown and read aloud; mic opens only **after** playback stops
   (SC-002 / Principle II).
3. Recite, then pause ~1.5–2 s → advances exactly one phrase (SC-001 / Principle IV).
4. Turn voice detection off in Settings → complete the list with تم/تجاوز only (SC-003).
5. A single cough before reciting does **not** advance (SC-007).
6. Set a reminder a minute out → notification fires; reboot → it still fires (SC-006).
7. Diff `assets/azkar.json` against the stakeholder source → byte-identical (SC-008).

### Hands-free / driving mode (US6, FR-024–FR-030)

1. Hands-free is **on by default** (Settings → "وضع القيادة"). In a session the app
   **announces the count** ("ثلاث مرات") then reads the phrase, plays a cue between phrases, and
   announces start/finish — complete a list **without looking at or touching the screen** (SC-009).
2. Turn voice detection **off** → hands-free auto-disables (FR-030 invariant).
3. Tap a delivered reminder → it opens **straight into that session** (SC-010 / FR-027).
4. On a device with **no Arabic TTS voice**, a session runs text-only with a one-time notice
   (FR-028); backgrounding then returning **replays the current phrase** (FR-029).

## Key files to read first

- `specs/001-azkar-session/contracts/session-engine.md` — the core state machine + invariants.
- `lib/session/session_controller.dart` — implementation of that contract.
- `assets/azkar.json` — sacred content; never edit casually (see constitution Principle I).
