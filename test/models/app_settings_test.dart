import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/app_settings.dart';

void main() {
  group('AppSettings FR-030 invariant (hands-free ⇒ voice on)', () {
    test('enabling hands-free forces voice detection on', () {
      const s = AppSettings(voiceDetectionEnabled: false, handsFreeMode: false);
      final next = s.copyWith(handsFreeMode: true);
      expect(next.handsFreeMode, isTrue);
      expect(next.voiceDetectionEnabled, isTrue);
    });

    test('disabling voice detection forces hands-free off', () {
      const s = AppSettings(voiceDetectionEnabled: true, handsFreeMode: true);
      final next = s.copyWith(voiceDetectionEnabled: false);
      expect(next.voiceDetectionEnabled, isFalse);
      expect(next.handsFreeMode, isFalse);
    });

    test('fromJson enforces the invariant (voice off ⇒ hands-free off)', () {
      final s = AppSettings.fromJson(const {
        'voiceDetectionEnabled': false,
        'handsFreeMode': true,
      });
      expect(s.voiceDetectionEnabled, isFalse);
      expect(s.handsFreeMode, isFalse);
    });

    test('JSON round-trip preserves handsFreeMode', () {
      const s = AppSettings(handsFreeMode: true, sensitivity: 0.7);
      final back = AppSettings.fromJson(s.toJson());
      expect(back.handsFreeMode, isTrue);
      expect(back.sensitivity, 0.7);
    });

    test('defaults: hands-free on and voice on', () {
      const s = AppSettings();
      expect(s.handsFreeMode, isTrue);
      expect(s.voiceDetectionEnabled, isTrue);
    });
  });
}
