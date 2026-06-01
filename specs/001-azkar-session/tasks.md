# Tasks: Guided Azkar Session (أذكار الصباح والمساء)

**Feature**: `001-azkar-session` | **Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)

**Status**: regenerated from design artifacts; completion re-applied. Phase 9 (driving mode) added.
**Progress**: 60 / 62 complete. Phase 9 (driving mode) implemented.
- Core feature (T001–T047): 45 done; open **T043** (on-device VAD tuning), **T045** (Arabic-speaker
  review) — both need external resources.
- **Phase 9 / US6 hands-free driving mode (T048–T062): not yet implemented** — this is the next
  `/speckit-implement` target.

Tests for the two NON-NEGOTIABLE behaviors are **required** by the constitution:
PLAY→STOP→LISTEN ordering (Principle II) and one-advance-per-phrase (Principle IV). Other tests are
included where they protect a constitutional guarantee (sacred-text integrity, date-rollover,
no-network).

**Conventions**: `[P]` = parallelizable (different file, no incomplete deps). Story labels
`[US1]`..`[US5]` map to the spec's user stories. Run `source scripts/env.sh` before any
flutter/dart command.

---

## Phase 1: Setup

- [x] T001 Scaffold platform folders: `flutter create . --org com.hesn --project-name hesn --platforms android,ios`; confirm `pubspec.yaml`/`lib/` preserved.
- [x] T002 Reconcile `pubspec.yaml` with locked deps (flutter_tts, record, flutter_local_notifications, timezone, flutter_timezone, shared_preferences, permission_handler, intl, flutter_localizations); declare `assets/azkar.json` + Amiri font; `flutter pub get`.
- [x] T003 [P] Bundle Naskh font with tashkīl support in `assets/fonts/` (Amiri) and declare in `pubspec.yaml`.
- [x] T004 [P] `analysis_options.yaml` with `flutter_lints`; verify `flutter analyze` runs clean.
- [x] T005 [P] Android manifest: `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, notification boot receiver; `minSdk 26` in `android/app/build.gradle.kts`.
- [x] T006 [P] iOS `Info.plist`: `NSMicrophoneUsageDescription` (Arabic + English) — mic only detects recitation completion.

**Checkpoint**: `flutter analyze` clean; `flutter build apk --debug` succeeds. ✅

---

## Phase 2: Foundational (blocking prerequisites for all stories)

- [x] T007 [P] `AzkarType` + `SessionPhase` enums (`lib/models/azkar.dart`, `lib/session/session_phase.dart`).
- [x] T008 [P] `AzkarItem`/`AzkarList` models with `fromJson` + validation (`repeat>=1`, `quran ⇒ ref`) in `lib/models/azkar.dart`.
- [x] T009 [P] `AppSettings` model (`lib/models/app_settings.dart`).
- [x] T010 [P] `DailyProgress` model with date-rollover rule (`lib/models/daily_progress.dart`).
- [x] T011 Create `assets/azkar.json` from committed source `source/azkar-source.txt` — morning + evening, voweled, **verbatim**, quran items flagged with `ref`, repeat counts exact.
- [x] T012 Validate `assets/azkar.json` against `contracts/azkar.schema.json`; fix structure only, never the sacred text.
- [x] T013 [P] Service interfaces in `lib/services/` (TtsService, VadService, StorageService, NotificationService, PermissionService).
- [x] T014 [P] `AzkarRepository` (read-only asset load) in `lib/data/azkar_repository.dart`.
- [x] T015 [P] [TEST] `test/data/azkar_repository_test.dart`: parses; quran items have ref; byte-stable text.
- [x] T016 [P] [TEST] `test/models/daily_progress_test.dart`: date-rollover reset; same-day preserve.
- [x] T017 [P] Arabic RTL theme + app shell (`lib/theme/app_theme.dart`, `lib/app.dart`, `lib/main.dart`).
- [x] T018 Test fakes in `test/fakes/` (FakeTts/FakeVad/FakeStorage/FakePermission + call-order log).

**Checkpoint**: models + data load + theme; foundational tests green. ✅

---

## Phase 3: User Story 1 — Complete a session by voice (P1) 🎯 MVP

- [x] T019 [P] [US1] [TEST] `test/session/session_controller_test.dart`: INV-1/2 mic only after stop; INV-3 single advance; INV-4 list-complete once.
- [x] T020 [P] [US1] [TEST] `test/session/vad_detector_test.dart`: min-speech rejects blip; silence-window completes once; safety-timeout flag.
- [x] T021 [US1] `VadDetector` (`lib/session/vad_detector.dart`).
- [x] T022 [US1] `SessionController` state machine (`lib/session/session_controller.dart`).
- [x] T023 [US1] `FlutterTtsService` (`lib/services/tts_service.dart`) — awaitSpeakCompletion, ar.
- [x] T024 [US1] `RecordVadService` amplitude-only, no file/STT (`lib/services/vad_service.dart`).
- [x] T025 [US1] `SessionScreen` voice path (`lib/screens/session_screen.dart`).
- [x] T026 [P] [US1] `azkar_text_view.dart` + `repeat_counter.dart` widgets.

**Checkpoint**: list completable by voice; invariant tests pass. ✅ (MVP)

---

## Phase 4: User Story 2 — Manual Done/Skip + safety timeout (P1)

- [x] T027 [P] [US2] [TEST] `test/widget/session_screen_test.dart`: تم/تجاوز always present; manual-only with voice off.
- [x] T028 [US2] Done/Skip buttons wired to `advance()`/`skip()`, always visible.
- [x] T029 [US2] Honor `voiceDetectionEnabled=false` (skip listening, no VAD).
- [x] T030 [US2] Surface safety-timeout (emphasize Done).

**Checkpoint**: full list completable with zero voice. ✅

---

## Phase 5: User Story 3 — Today's progress & resume (P2)

- [x] T031 [US3] `SharedPrefsStorageService` with rollover reset + markListComplete (`lib/services/storage_service.dart`).
- [x] T032 [US3] Persist completion on `onListComplete`.
- [x] T033 [US3] `HomeScreen` with per-list status + entries (`lib/screens/home_screen.dart`).
- [x] T034 [P] [US3] `progress_badge.dart` widget.

**Checkpoint**: progress visible and resets across days. ✅

---

## Phase 6: User Story 4 — Daily reminders (P2)

- [x] T035 [US4] `LocalNotificationService`: tz init, zonedSchedule daily morning+evening, reschedule (`lib/services/notification_service.dart`).
- [x] T036 [US4] init + rescheduleFromSettings on launch (`lib/main.dart`).
- [x] T037 [US4] Android boot receiver re-registers reminders; OEM battery caveat documented.

**Checkpoint**: reminders fire daily and after reboot (code complete; live verify in T043 device pass). ✅

---

## Phase 7: User Story 5 — Settings & mic permission (P3)

- [x] T038 [US5] `PermissionHandlerService` (`lib/services/permission_service.dart`).
- [x] T039 [US5] Arabic mic-rationale dialog before first request; deny → manual-only.
- [x] T040 [US5] `SettingsScreen`: reminder times, voice toggle, sensitivity; persist + reschedule (`lib/screens/settings_screen.dart`).

**Checkpoint**: settings persist and take effect. ✅

---

## Phase 8: Polish & Cross-Cutting

- [x] T041 [P] Lifecycle teardown: stop TTS + VAD on background/pause (`WidgetsBindingObserver`).
- [x] T042 [P] In-app Arabic privacy notice (Settings).
- [ ] T043 [P] Tune timing defaults (silence window, min-speech, sensitivity) on a **real Android device**; record final values in `contracts/session-engine.md`. ⛔ needs hardware.
- [x] T044 Final gates: `flutter analyze` clean, `flutter test` green, debug APK builds.
- [ ] T045 Pre-release: **competent Arabic speaker** reviews `assets/azkar.json` vs source (Principle I) and records sign-off. ⛔ needs human reviewer.
- [x] T046 [P] [TEST] No-network guard `test/privacy/no_network_test.dart` (Principle III / FR-021).
- [x] T047 [P] [TEST] Sacred-text source-diff `test/data/azkar_source_diff_test.dart` (Principle I / SC-008); diffs azkar.json against `source/azkar-source.txt` + `source/azkar-evening-variants.txt`.

---

## Phase 9: User Story 6 — Hands-free / Driving Mode (P1) 🚗

**Goal**: Eyes-free, no-touch use while driving (FR-024–FR-030): app speaks the count, reads the
phrase, cues transitions, announces start/finish, advances by voice, and can start from the
reminder — all without looking at or touching the screen. Lifecycle adds an `announcing` phase
(ANNOUNCE→PLAY→STOP→LISTEN). **Not yet implemented.**

**Independent test**: With fakes, a hands-free session announces the count phrase then reads the
phrase, opens the mic only after stop, and advances once on voice-complete — no taps; on a device,
complete a list without looking at the screen.

- [x] T048 [US6] Add `handsFreeMode` (default true) to `AppSettings` (`lib/models/app_settings.dart`) with the FR-030 invariant helper: enabling hands-free implies `voiceDetectionEnabled=true`; disabling voice forces `handsFreeMode=false`.
- [x] T049 [P] [US6] [TEST] `test/models/app_settings_test.dart`: FR-030 invariant (hands-free⇒voice-on; voice-off⇒hands-free-off) + JSON round-trip incl. `handsFreeMode`.
- [x] T050 [US6] Add `countPhrase` to each multi-repeat item in `assets/azkar.json` using the source's canonical Arabic wording (3→ثلاث مرات, 4→أربع مرات, 7→سبع مرات, 10→عشر مرات, 100→مائة مرة); update `source/azkar-source.txt` coverage so T047 still passes.
- [x] T051 [US6] Add `countPhrase` (`String?`) to `AzkarItem.fromJson`/model (`lib/models/azkar.dart`); extend `test/data/azkar_repository_test.dart` to assert multi-repeat items carry a `countPhrase`.
- [x] T052 [P] [US6] [TEST] `test/session/announcer_test.dart`: `Announcer` returns the item's `countPhrase` for repeat>1 and null for repeat==1.
- [x] T053 [US6] Implement `Announcer` (`lib/session/announcer.dart`) — pure Dart: count announcement text + cue plan from an `AzkarItem` (FR-025).
- [x] T054 [US6] Add `announcing` to `SessionPhase` and the announce step to `SessionController` (ANNOUNCE→PLAY→STOP→LISTEN, gated by hands-free; mic still only opens in `listening`). Update `test/session/session_controller_test.dart` for the new phase ordering + INV-6.
- [x] T055 [P] [US6] Implement `CueService` (`lib/services/cue_service.dart`) using `SystemSound`/`HapticFeedback` — transition cue; spoken start/finish announcements via `TtsService` from the controller (FR-026).
- [x] T056 [US6] Add `TtsService.hasArabicVoice()` (`lib/services/tts_service.dart`); when false, session runs text-only (skip announcements + reading) and shows a one-time Arabic notice (FR-028).
- [x] T057 [US6] Notification → immediate start: `NotificationService.init(onTapList)` + per-notification `payload(listId)`; `lib/main.dart` routes a reminder tap straight into that list's session (FR-027).
- [x] T058 [US6] Resume-replay: on `AppLifecycleState.resumed` with an active session, re-enter the current item at `announcing` (re-announce + re-read) instead of staying paused (FR-029).
- [x] T059 [US6] `SettingsScreen` hands-free toggle (default on) wired to the FR-030 invariant against the voice toggle; persist via `StorageService`.
- [x] T060 [US6] Eyes-free wiring in `SessionScreen`: announce count → read → cue on transition → spoken session start/finish; keep a glanceable large RTL layout; ensure a full list completes with zero taps.
- [x] T061 [P] [US6] [TEST] `test/widget/hands_free_session_test.dart`: with FakeTts capturing utterances, a hands-free session announces the count phrase before the phrase, advances on voice-complete with no taps, and the FR-030 toggle interaction holds.
- [x] T062 Update `quickstart.md` with driving-mode verification steps; re-run `flutter analyze` + `flutter test`; rebuild debug APK.

**Checkpoint**: a list completes hands-free (announce → recite → auto-advance) with no taps; the
`announcing` phase preserves PLAY→STOP→LISTEN; FR-030 invariant enforced.

---

## Dependencies & Execution Order

Setup → Foundational block all stories. US1 (MVP) → US2 (same screen). US3/US4/US5 independent of
US1/US2 after Foundational; US5 settings feed US4 reschedule. **US6 (driving) builds on the US1
session engine + US5 settings** (it extends `SessionController`/`SessionScreen` and adds the
hands-free toggle) and on US4 notifications (tap-to-start); do US6 after US1–US5. Polish last.
Story order: US1 → US2 → US3 → US4 → US5 → US6.

## Parallel Opportunities

Setup T003–T006; Foundational T007–T010/T013–T017; US1 T019/T020/T026; tests across stories.

## Independent Test Criteria

- US1: speech→silence advances one phrase; mic never opens during playback; list completes.
- US2: voice off → finish via تم/تجاوز; timeout emphasizes Done.
- US3: completion shown on Home; resets on date change.
- US4: reminder fires at set time and after reboot.
- US5: settings persist across restart and change behavior.
- US6 (driving): a list completes with zero taps — count announced, phrase read, mic only after stop,
  auto-advance on voice-complete; reminder tap starts the session; FR-030 toggle invariant holds.

## MVP

Phases 1 + 2 + 3 (US1) — hands-free session with the PLAY→STOP→LISTEN guarantee; add US2
immediately for the constitution-required manual fallback. **Delivered.**

## Remaining Work

**Hands-free / driving mode (T048–T062)** — buildable now; the next `/speckit-implement` target.

**External gates (cannot be done in this environment):**

| Task | Blocker | Needed to |
|------|---------|-----------|
| T043 | physical Android device | tune VAD silence/min-speech/sensitivity (incl. inter-repetition gap for hands-free) |
| T045 | competent Arabic speaker | sign off azkar text/counts (incl. evening variants + count phrases) before public release |
