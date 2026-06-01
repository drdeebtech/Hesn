# Contract: Session Engine (PLAY → STOP → LISTEN)

The `SessionController` is pure Dart. It depends only on `TtsService` and `VadService` interfaces
(injected). It owns the state machine that encodes Constitution Principles II and IV. This contract
is the basis for `test/session/session_controller_test.dart`.

## State machine

```
        start(list)
 idle ───────────────▶ playing
                         │  tts.speak(item.text) ; await completion
                         ▼
                      stopping        (tts.stop(); guard delay ~250ms)
                         │
              ┌──────────┴───────────┐
   voice on   │                      │  voice off (settings)
              ▼                      ▼
          listening              advancing ──┐
   vad.start(); watch amplitude              │
   ┌─────────────────────────────┐          │
   │ spoke ≥ minSpeech AND        │          │
   │ then silence ≥ silenceWindow │──advance─┤
   │ OR user taps "تم"            │          │
   │ OR user taps "تجاوز"         │          │
   └─────────────────────────────┘          │
                         vad.stop()          │
                                             ▼
                                   index+1 < n ? playing : done
```

## Invariants (test-enforced)

- **INV-1 (Principle II)**: `VadService.start()` is never called while a TTS utterance is active.
  The controller must have observed TTS completion/stop and passed through `stopping` before
  entering `listening`. Test: a fake TTS that reports "still speaking" must cause any mic-start
  attempt to throw / fail the test.
- **INV-2 (Principle II)**: Entering `listening` always follows a `stopping` in which
  `TtsService.stop()` resolved. No transition `playing → listening` directly.
- **INV-3 (Principle IV)**: Each of {voice-complete, Done, Skip} advances `index` by exactly 1. No
  path advances more than once for a single phrase. `repeat` never triggers an advance.
- **INV-4**: On `done`, the active list is reported complete exactly once.
- **INV-5 (Principle III/VII)**: Leaving `listening` for any reason calls `VadService.stop()`.
  Session teardown (exit/pause/background) calls both `tts.stop()` and `vad.stop()`.

## Public surface (Dart-ish signature)

```dart
class SessionController {
  SessionController({required TtsService tts, required VadService vad,
                     required bool voiceEnabled, required double sensitivity});

  SessionPhase get phase;
  AzkarItem get currentItem;
  int get index;             // 0-based
  int get total;
  bool get safetyTimeoutElapsed;

  void start(AzkarList list);
  void advance();            // used by voice-complete, Done, and Skip (single step)
  void skip();               // advance without marking recited (same index step)
  void pause();              // stop tts + vad, hold phase
  void dispose();            // stop everything, release

  // observation (hand-rolled; no state-mgmt lib)
  void addListener(VoidCallback l);
  void removeListener(VoidCallback l);

  // completion callback
  set onListComplete(void Function(String listId) cb);
}
```

## Timing parameters (defaults; tunable)

| Param           | Default      | Source |
|-----------------|--------------|--------|
| stop guard      | 250 ms       | route teardown before mic |
| minSpeech       | ~max(0.6s, 0.04s × textChars) | reject coughs (FR-006) |
| silenceWindow   | 1.5–2.0 s    | "finished reciting" (FR-005) |
| safetyTimeout   | 8–10 s       | surface Done (FR-009) |
| amplitude poll  | 100–200 ms   | VAD sampling |
