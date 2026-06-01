/// Pure, time-driven voice-activity logic. No plugins, no wall clock — callers
/// feed it amplitude samples with the elapsed time since the previous sample,
/// which makes it fully deterministic to unit-test.
///
/// Rule (FR-005, FR-006, FR-009): require a minimum cumulative amount of
/// detected speech, then once the user has spoken, a silence window of
/// sub-threshold level signals "finished". If no speech is detected within the
/// safety timeout, [safetyTimeoutElapsed] becomes true so the UI can emphasize
/// the Done button.
class VadDetector {
  VadDetector({
    required double sensitivity,
    this.minSpeech = const Duration(milliseconds: 600),
    this.silenceWindow = const Duration(milliseconds: 1700),
    this.safetyTimeout = const Duration(seconds: 9),
  }) : threshold = _thresholdFor(sensitivity);

  /// 0..1 loudness threshold above which a sample counts as speech.
  final double threshold;
  final Duration minSpeech;
  final Duration silenceWindow;
  final Duration safetyTimeout;

  Duration _speechElapsed = Duration.zero;
  Duration _silenceElapsed = Duration.zero;
  Duration _totalElapsed = Duration.zero;
  bool _hasSpoken = false;
  bool _safetyTimeoutElapsed = false;
  bool _completed = false;

  bool get hasSpoken => _hasSpoken;
  bool get safetyTimeoutElapsed => _safetyTimeoutElapsed;

  /// Higher sensitivity => lower threshold (easier to count as speech).
  static double _thresholdFor(double sensitivity) {
    final s = sensitivity.clamp(0.0, 1.0);
    return 0.45 - 0.40 * s; // s=0 -> 0.45 ; s=1 -> 0.05
  }

  /// Feeds one amplitude [level] (0..1) observed [sinceLast] after the previous
  /// sample. Returns true exactly once when recitation is judged complete.
  bool addSample(double level, Duration sinceLast) {
    if (_completed) return false; // fire exactly once until reset()
    _totalElapsed += sinceLast;

    if (level >= threshold) {
      _speechElapsed += sinceLast;
      _silenceElapsed = Duration.zero;
      if (_speechElapsed >= minSpeech) _hasSpoken = true;
    } else {
      if (_hasSpoken) {
        _silenceElapsed += sinceLast;
        if (_silenceElapsed >= silenceWindow) {
          _completed = true;
          return true;
        }
      } else if (_totalElapsed >= safetyTimeout) {
        _safetyTimeoutElapsed = true;
      }
    }
    return false;
  }

  void reset() {
    _speechElapsed = Duration.zero;
    _silenceElapsed = Duration.zero;
    _totalElapsed = Duration.zero;
    _hasSpoken = false;
    _safetyTimeoutElapsed = false;
    _completed = false;
  }
}
