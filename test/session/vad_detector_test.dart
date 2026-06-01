import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/session/vad_detector.dart';

void main() {
  group('VadDetector', () {
    test('a brief blip (cough) before min-speech does NOT complete', () {
      final d = VadDetector(
        sensitivity: 0.5,
        minSpeech: const Duration(milliseconds: 600),
        silenceWindow: const Duration(milliseconds: 1700),
      );
      // 200ms of loud, then long silence -> not enough speech to count.
      var done = d.addSample(0.9, const Duration(milliseconds: 200));
      expect(done, isFalse);
      for (var i = 0; i < 20; i++) {
        done = d.addSample(0.0, const Duration(milliseconds: 200));
        expect(done, isFalse);
      }
      expect(d.hasSpoken, isFalse);
    });

    test('speech then silence window completes exactly once', () {
      final d = VadDetector(
        sensitivity: 0.5,
        minSpeech: const Duration(milliseconds: 600),
        silenceWindow: const Duration(milliseconds: 1700),
      );
      // ~800ms of speech
      for (var i = 0; i < 4; i++) {
        expect(d.addSample(0.9, const Duration(milliseconds: 200)), isFalse);
      }
      expect(d.hasSpoken, isTrue);
      // silence accumulates; completes once it crosses the window
      var completions = 0;
      for (var i = 0; i < 12; i++) {
        if (d.addSample(0.0, const Duration(milliseconds: 200))) completions++;
      }
      expect(completions, 1);
    });

    test('safety timeout fires when no speech is detected', () {
      final d = VadDetector(
        sensitivity: 0.5,
        safetyTimeout: const Duration(seconds: 9),
      );
      for (var i = 0; i < 50; i++) {
        d.addSample(0.0, const Duration(milliseconds: 200)); // 10s of silence
      }
      expect(d.safetyTimeoutElapsed, isTrue);
      expect(d.hasSpoken, isFalse);
    });

    test('higher sensitivity lowers the threshold', () {
      final low = VadDetector(sensitivity: 0.0);
      final high = VadDetector(sensitivity: 1.0);
      expect(high.threshold, lessThan(low.threshold));
    });
  });
}
