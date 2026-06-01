import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/azkar.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';
import 'session_phase.dart';
import 'vad_detector.dart';

/// Drives one azkar list through the strict PLAY -> STOP -> LISTEN lifecycle.
///
/// Pure-ish controller: depends only on [TtsService] and [VadService]
/// abstractions (no widgets, no direct plugins) so the constitutional
/// invariants (Principle II ordering, Principle IV single-advance) are
/// unit-testable with fakes. Observers register via [addListener].
class SessionController {
  SessionController({
    required TtsService tts,
    required VadService vad,
    required bool voiceEnabled,
    required double sensitivity,
    Duration stopGuard = const Duration(milliseconds: 250),
  })  : _tts = tts,
        _vad = vad,
        _voiceEnabled = voiceEnabled,
        _sensitivity = sensitivity,
        _stopGuard = stopGuard;

  final TtsService _tts;
  final VadService _vad;
  final bool _voiceEnabled;
  final double _sensitivity;
  final Duration _stopGuard;

  final List<VoidCallback> _listeners = [];
  void Function(String listId)? onListComplete;

  late AzkarList _list;
  int _index = 0;
  SessionPhase _phase = SessionPhase.idle;
  bool _ttsSpeaking = false;
  bool _advanceInFlight = false;

  StreamSubscription<double>? _vadSub;
  VadDetector? _detector;
  Stopwatch? _sampleClock;
  Timer? _safetyTimer;
  bool _safetyTimeoutElapsed = false;

  // ---- public state ----
  SessionPhase get phase => _phase;
  int get index => _index;
  int get total => _list.length;
  AzkarItem get currentItem => _list.items[_index];
  bool get isVoiceEnabled => _voiceEnabled;
  bool get safetyTimeoutElapsed => _safetyTimeoutElapsed;
  bool get ttsSpeaking => _ttsSpeaking;

  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);
  void _notify() {
    for (final l in List<VoidCallback>.of(_listeners)) {
      l();
    }
  }

  // ---- lifecycle ----
  Future<void> start(AzkarList list) async {
    _list = list;
    _index = 0;
    await _tts.init();
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    _cancelListening();
    _safetyTimeoutElapsed = false;
    _phase = SessionPhase.playing;
    _ttsSpeaking = true;
    _notify();

    await _tts.speak(currentItem.text); // resolves when playback finishes
    _ttsSpeaking = false;

    await _stopThenListen();
  }

  Future<void> _stopThenListen() async {
    // STOP: fully stop playback before the mic may open (Principle II).
    _phase = SessionPhase.stopping;
    _notify();
    await _tts.stop();
    if (_stopGuard > Duration.zero) await Future<void>.delayed(_stopGuard);

    // LISTEN: now (and only now) is it safe to open the mic.
    _phase = SessionPhase.listening;
    _notify();

    if (_voiceEnabled) {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!await _vad.hasPermission()) return; // manual-only fallback
    _detector = VadDetector(sensitivity: _sensitivity);
    _sampleClock = Stopwatch()..start();
    _safetyTimer = Timer(_detector!.safetyTimeout, () {
      if (_detector != null && !_detector!.hasSpoken) {
        _safetyTimeoutElapsed = true;
        _notify();
      }
    });
    _vadSub = _vad.start(sensitivity: _sensitivity).listen((level) {
      final elapsed = _sampleClock!.elapsed;
      _sampleClock!
        ..reset()
        ..start();
      final complete = _detector!.addSample(level, elapsed);
      if (complete) advance();
    });
  }

  void _cancelListening() {
    final wasListening = _vadSub != null;
    _vadSub?.cancel();
    _vadSub = null;
    _safetyTimer?.cancel();
    _safetyTimer = null;
    _detector = null;
    _sampleClock = null;
    // Only touch the mic if we had actually started listening.
    if (wasListening) _vad.stop();
  }

  /// Advance exactly one phrase. Used by voice-complete and the Done button.
  /// Re-entrant calls while an advance is in flight are ignored (Principle IV).
  void advance() {
    if (_advanceInFlight) return;
    if (_phase != SessionPhase.listening) return;
    _advanceInFlight = true;
    _cancelListening();
    _phase = SessionPhase.advancing;
    _notify();

    if (_index + 1 < _list.length) {
      _index += 1;
      _advanceInFlight = false;
      _playCurrent();
    } else {
      _phase = SessionPhase.done;
      _advanceInFlight = false;
      _notify();
      onListComplete?.call(_list.id);
    }
  }

  /// Skip the current phrase (same single-step movement as [advance]).
  void skip() => advance();

  void pause() {
    _cancelListening();
    _tts.stop();
  }

  void dispose() {
    _cancelListening();
    _tts.stop();
    _listeners.clear();
  }
}
