# Feature Specification: Guided Azkar Session (أذكار الصباح والمساء)

**Feature Branch**: `001-azkar-session`

**Created**: 2026-06-01

**Status**: Draft

**Input**: User description: "Morning & evening azkar app (حصن / Hesn) — a guided dhikr session that reads each phrase aloud, listens only to confirm the user finished reciting, then advances; with manual Done/Skip fallback, daily reminders, local progress, and Arabic RTL UI."

## Clarifications

### Session 2026-06-01

- Q: v1 release rule for the evening azkar (6 variants transcribed because the source truncated them)? → A: Block public release until the evening list is verbatim-complete and signed off by a competent Arabic speaker (T045).
- Q: Behavior when the device has no Arabic TTS voice installed? → A: Fall back to text-only (no audio), keep the session fully usable via manual/VAD, and show a one-time notice.
- Q: Behavior when a session is interrupted (call/backgrounded) on return? → A: Keep the user's place and replay the current phrase from the start (PLAY→STOP→LISTEN restarts for that item).
- Q: Default VAD timings? → A: Silence-to-advance 1.8s; safety timeout 9s; minimum speech scales with phrase length.
- Q: Primary use context and interaction model? → A: Used while driving — a full audio-first, eyes-free, no-touch mode is the primary experience: the app speaks each phrase, announces transitions and session start/finish, and advances by voice, so the user never needs to look at or tap the phone.
- Q: How are repeat counts conveyed when the screen can't be seen? → A: The app audibly announces the count (e.g. "ثلاث مرات") then reads the phrase once; the user recites it the stated number of times and pauses to advance (still one advance per phrase).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete a guided morning/evening session by voice (Priority: P1)

A user opens the app, chooses أذكار الصباح (or أذكار المساء), and is guided phrase by phrase.
For each phrase the app displays the fully-voweled Arabic text and its repeat count, reads the
phrase aloud, then — once playback has fully stopped — listens through the microphone. When it
detects the user recited and then paused, it advances to the next phrase. The user works through
the whole list hands-free and the session is marked complete for the day.

**Why this priority**: This is the core product — the hands-free, listen-to-advance dhikr flow.
Without it there is no app. It alone delivers the central value.

**Independent Test**: Launch a session for a list, recite (or simulate speech then silence) for
each phrase, and confirm the app advances one phrase at a time and marks the list complete at the
end — without any other feature present.

**Acceptance Scenarios**:

1. **Given** a session showing phrase N, **When** the phrase finishes playing and the user speaks
   then stays silent for the silence threshold, **Then** the app advances to phrase N+1 exactly
   once.
2. **Given** the app is still reading a phrase aloud, **When** the user remains silent, **Then**
   the microphone is not yet listening and no advance occurs (audio playback and listening never
   overlap).
3. **Given** the last phrase of a list is completed, **When** it advances, **Then** the session is
   marked complete for today for that list and the user is returned to a completion state.
4. **Given** a phrase with a repeat count greater than one, **When** the user recites and pauses,
   **Then** the app advances to the next phrase once (it does not advance once per repeat).

### User Story 2 - Manual control with Done and Skip (Priority: P1)

At any time during a session the user can tap "تم" (Done) to advance the current phrase, or
"تجاوز" (Skip) to move past it. These controls are always visible and work whether or not voice
detection is enabled. If the app does not detect speech within a short safety window, the Done
button is clearly surfaced so the user is never stuck.

**Why this priority**: Voice detection is probabilistic; a guaranteed manual path is required for
the app to be usable by everyone, in any environment. It is co-critical with Story 1.

**Independent Test**: With voice detection turned off entirely, walk through a full list using only
Done/Skip and confirm the session completes correctly.

**Acceptance Scenarios**:

1. **Given** any phrase in a session, **When** the user taps "تم", **Then** the app advances one
   phrase.
2. **Given** any phrase in a session, **When** the user taps "تجاوز", **Then** the app moves past
   that phrase without marking it as recited.
3. **Given** voice detection is enabled but no speech is detected within the safety timeout
   (8–10 seconds), **When** the timeout elapses, **Then** the Done button is clearly emphasized so
   the user can advance manually.
4. **Given** voice detection is disabled in settings, **When** a session runs, **Then** phrases are
   read aloud and advance only via Done/Skip.

### User Story 3 - See today's progress and resume (Priority: P2)

From the home screen the user sees whether the morning list and the evening list are completed
today. Completion status resets automatically when the calendar day changes, so each new day starts
fresh.

**Why this priority**: Progress visibility is the main retention and reassurance feature, but the
app is usable without it.

**Independent Test**: Complete the morning list, return home, confirm morning shows completed and
evening shows not completed; simulate a date change and confirm both reset to not completed.

**Acceptance Scenarios**:

1. **Given** the morning list was completed today, **When** the user views the home screen, **Then**
   the morning entry shows a completed status and the evening entry shows not completed.
2. **Given** a list was completed on a previous day, **When** the calendar date changes, **Then**
   that list's status resets to not completed.

### User Story 4 - Daily morning and evening reminders (Priority: P2)

The user sets a morning reminder time and an evening reminder time. The app delivers a local
notification at each time every day to prompt the user to perform the azkar. Reminders persist and
continue to fire after the device restarts.

**Why this priority**: Reminders drive the daily habit, but the core session works without them.

**Independent Test**: Set a reminder a minute ahead, confirm a notification fires; restart the
device and confirm the scheduled reminders still fire.

**Acceptance Scenarios**:

1. **Given** a morning reminder time is set, **When** that time arrives, **Then** a local
   notification is delivered prompting the morning azkar.
2. **Given** reminders are scheduled, **When** the device reboots, **Then** the reminders are
   re-established and continue to fire at their set times.
3. **Given** the user changes a reminder time, **When** the new time arrives, **Then** the
   notification fires at the new time and not the old one.

### User Story 5 - Configure voice detection and reminders (Priority: P3)

In settings the user can enable or disable voice detection globally, adjust voice-detection
sensitivity, and set the morning and evening reminder times. Settings persist across app restarts.

**Why this priority**: Tuning improves the experience across noisy environments and quiet reciters,
but sensible defaults make the app usable without ever opening settings.

**Independent Test**: Change each setting, restart the app, and confirm the new values are retained
and take effect.

**Acceptance Scenarios**:

1. **Given** the settings screen, **When** the user disables voice detection, **Then** subsequent
   sessions run without opening the microphone.
2. **Given** the settings screen, **When** the user adjusts sensitivity, **Then** the change affects
   how readily speech is detected in the next session.
3. **Given** settings were changed, **When** the app is closed and reopened, **Then** the saved
   values are still in effect.

### Edge Cases

- **Microphone permission denied or revoked**: The session MUST continue to work using Done/Skip,
  and the app MUST clearly explain (in Arabic) why the mic was requested without blocking the user.
- **Noise / cough before recitation**: A per-phrase minimum speech duration MUST prevent brief
  noise from advancing the phrase early.
- **Very quiet recitation**: The Done button remains available and the safety timeout surfaces it;
  sensitivity can be increased in settings.
- **App interrupted mid-session** (call, backgrounded): Audio playback and the mic MUST stop; on
  return the app MUST keep the user's place and replay the current phrase from the start
  (PLAY→STOP→LISTEN restarts for that item), so an eyes-free user is not stranded.
- **No Arabic TTS voice installed**: The app MUST fall back to text-only (no audio) while keeping
  the session fully usable, and show a one-time notice. (Eyes-free use is degraded in this state.)
- **Multi-repeat item while hands-free** (e.g. ×3, ×10, ×100): the silence-to-advance window MUST be
  tuned so brief pauses between repetitions do not advance early; advancing relies on a deliberate
  longer pause after the final repetition. Final values set during on-device tuning.
- **Date rolls over mid-session** (session started before midnight): Completion is recorded against
  the day the session is completed.
- **Reminder time already passed today**: The next occurrence MUST be scheduled for the following
  day.
- **Repeat count of a phrase**: Displayed for the user; never used to auto-advance per repeat.

## Requirements *(mandatory)*

### Functional Requirements

**Content & integrity**

- **FR-001**: The app MUST present azkar for two lists, أذكار الصباح (morning) and أذكار المساء
  (evening), sourced from Hisn al-Muslim, fully voweled, and used unaltered.
- **FR-002**: The app MUST display each phrase's repeat count as specified by the source, without
  modifying it.
- **FR-003**: Qur'anic items (e.g., Ayat al-Kursi, al-Ikhlas, al-Falaq, al-Nas) MUST be flagged as
  Qur'an and treated as immutable; the app MUST NOT alter their text.

**Session flow**

- **FR-004**: For each phrase the app MUST read the phrase aloud, then fully stop playback, then
  begin listening — in that strict order, with no overlap between playback and listening.
- **FR-005**: The app MUST detect, by microphone audio level only, that the user has spoken and then
  remained silent for a configurable silence threshold (default 1.5–2 seconds), and on that event
  advance to the next phrase.
- **FR-006**: The app MUST require a per-phrase minimum amount of detected speech before an advance
  can be triggered by voice, to reject brief noise.
- **FR-007**: The app MUST advance exactly one phrase per voice-detected completion, per Done tap,
  or per Skip tap; it MUST NOT advance more than once per phrase automatically.
- **FR-008**: "تم" (Done) and "تجاوز" (Skip) controls MUST be visible and operable throughout every
  session, regardless of voice-detection state.
- **FR-009**: If no speech is detected within a safety timeout of 8–10 seconds, the app MUST clearly
  surface the Done control.
- **FR-010**: On completing the last phrase of a list, the app MUST mark that list complete for the
  current day.

**Progress & state**

- **FR-011**: The app MUST persist, on the device, today's completion state for the morning and
  evening lists and the date that state belongs to.
- **FR-012**: When the calendar date changes, the app MUST reset both lists' completion state to not
  completed.
- **FR-013**: The home screen MUST show the current day's completion status for each list and
  provide entry to start either list and to open settings.

**Reminders**

- **FR-014**: The app MUST allow the user to set a morning reminder time and an evening reminder
  time.
- **FR-015**: The app MUST deliver a local notification at each set reminder time every day.
- **FR-016**: The app MUST re-establish scheduled reminders after a device reboot.

**Settings**

- **FR-017**: The app MUST allow the user to enable or disable voice detection globally.
- **FR-018**: The app MUST allow the user to adjust voice-detection sensitivity.
- **FR-019**: The app MUST persist all settings (reminder times, voice-detection enabled,
  sensitivity) across restarts.

**Permissions & privacy**

- **FR-020**: The app MUST request microphone permission before its first listening session and
  MUST present an Arabic explanation of why the mic is used.
- **FR-021**: The app MUST NOT record audio, MUST NOT convert audio to text, and MUST NOT transmit
  any data off the device.
- **FR-022**: The microphone MUST be active only during an active session and released when the
  session ends or is interrupted.

**Language & layout**

- **FR-023**: The entire UI MUST be in Arabic with a right-to-left layout.

**Hands-free / eyes-free (driving) — primary mode**

- **FR-024**: A full session MUST be operable entirely by audio — the user MUST be able to start,
  progress through, and complete a list without looking at or touching the screen.
- **FR-025**: Before (or as) it reads each phrase, the app MUST audibly announce that phrase's
  repeat count (e.g. "ثلاث مرات"); for a count of one it MAY omit the announcement.
- **FR-026**: The app MUST announce session start and session completion audibly, and MUST give an
  audible cue at each phrase transition, so progress is perceivable without the screen.
- **FR-027**: The app MUST let the user begin the correct session (morning/evening) with a single
  action from the reminder notification (and/or auto-start the time-appropriate list), to avoid
  on-screen navigation while driving.
- **FR-028**: When no Arabic TTS voice is available, the app MUST fall back to text-only operation,
  keep the session usable, and show a one-time notice.
- **FR-029**: After an interruption (call/background), on return the app MUST keep the user's place
  and replay the current phrase from the start.

### Key Entities *(include if feature involves data)*

- **Azkar List**: A named collection (morning or evening) of ordered items. Attributes: identifier,
  Arabic title, ordered items.
- **Azkar Item**: A single phrase. Attributes: identifier, type (regular dhikr or Qur'an), fully
  voweled Arabic text, repeat count, source attribution, and (for Qur'an) a verse reference.
- **Daily Progress**: Per-day record of which lists are completed. Attributes: morning completed,
  evening completed, the date the record applies to.
- **Settings**: User preferences. Attributes: morning reminder time, evening reminder time,
  voice-detection enabled, voice-detection sensitivity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can complete a full morning or evening list hands-free (voice-advance only)
  from start to finish without tapping the screen, in a normal-quiet room.
- **SC-002**: In every session, listening never begins until the spoken phrase has finished
  playing — verified to occur 0% of the time that the mic opens during playback.
- **SC-003**: A user can complete a full list using only the Done/Skip buttons with voice detection
  turned off.
- **SC-004**: After completing a list, the home screen reflects that list as completed for the day
  within 1 second of returning.
- **SC-005**: Completion status for both lists shows as not completed on the first launch of a new
  calendar day, with no user action.
- **SC-006**: A reminder set for a given time is delivered at that time on the day it is set and on
  subsequent days, including after a device reboot.
- **SC-007**: Brief background noise (e.g., a single cough) before recitation does not advance the
  phrase.
- **SC-008**: All azkar text and repeat counts shown in the app match the stakeholder-provided
  Hisn al-Muslim source exactly, with no character-level differences, as confirmed by review.
- **SC-009**: A user can start, work through, and complete a full list **without ever looking at or
  touching the screen** — audio alone conveys the phrase, its repeat count, transitions, and
  completion (the driving scenario).
- **SC-010**: From a delivered reminder, the user can begin the correct session with a single action
  (one tap, or automatically) — no on-screen navigation required.

## Assumptions

- The full azkar text (morning and evening, with tashkīl and Qur'an flags) has been provided by the
  stakeholder and will be used verbatim; a competent Arabic speaker reviews the data file before
  release.
- The app targets a single device per user with no account; all data is local. No cross-device sync
  is expected.
- Audio output is via text-to-speech for the first release; pre-recorded audio may replace it later
  without changing the session flow.
- Default silence-to-advance threshold is 1.8 seconds and the safety timeout is 9 seconds; minimum
  speech scales with phrase length. Exact values (especially the inter-repetition gap for
  multi-repeat items in hands-free use) are tuned on real devices.
- The evening azkar list is NOT released publicly until it is verbatim-complete and signed off by a
  competent Arabic speaker; the six transcribed evening variants are provisional until then.
- Mobile platforms only: Android is the first release target, iOS follows. Web and desktop are out
  of scope.
- Sensible defaults for reminder times and sensitivity allow the app to be used without opening
  settings.
- Notification delivery is subject to OS power-management behavior; the app schedules reminders and
  reschedules after reboot, but cannot guarantee delivery against aggressive OS battery policies.
