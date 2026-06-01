import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/azkar.dart';
import 'package:hesn/session/session_controller.dart';
import 'package:hesn/session/session_phase.dart';

import '../fakes/fakes.dart';

AzkarList _list(int n) => AzkarList(
      id: 'morning',
      title: 'أذكار الصباح',
      items: [
        for (var i = 0; i < n; i++)
          AzkarItem(
            id: 'm_$i',
            type: AzkarType.dhikr,
            text: 'ذكر رقم $i',
            repeat: 1,
            source: 'حصن المسلم',
          ),
      ],
    );

void main() {
  group('SessionController — PLAY -> STOP -> LISTEN (Principle II)', () {
    test('mic starts only AFTER stop, never during speaking (INV-1/INV-2)',
        () async {
      final log = CallLog();
      final tts = FakeTtsService(log);
      final vad = FakeVadService(log);
      final c = SessionController(
        tts: tts,
        vad: vad,
        voiceEnabled: true,
        sensitivity: 0.5,
        stopGuard: Duration.zero,
      );

      await c.start(_list(2));

      // For the first phrase, the order must be: speak, stop, vad.start.
      expect(log.events.take(3).toList(), ['speak', 'stop', 'vad.start']);
      // vad.start never appears before its preceding stop.
      final firstStart = log.events.indexOf('vad.start');
      final firstStop = log.events.indexOf('stop');
      expect(firstStop, lessThan(firstStart));
      expect(c.phase, SessionPhase.listening);
      c.dispose();
    });

    test('voice disabled => mic is never opened (Principle III/VII)', () async {
      final log = CallLog();
      final c = SessionController(
        tts: FakeTtsService(log),
        vad: FakeVadService(log),
        voiceEnabled: false,
        sensitivity: 0.5,
        stopGuard: Duration.zero,
      );
      await c.start(_list(2));
      expect(log.events.contains('vad.start'), isFalse);
      expect(c.phase, SessionPhase.listening);
      c.dispose();
    });
  });

  group('SessionController — one advance per phrase (Principle IV)', () {
    test('advance moves exactly one step and ignores re-entrant calls',
        () async {
      final log = CallLog();
      final c = SessionController(
        tts: FakeTtsService(log),
        vad: FakeVadService(log),
        voiceEnabled: true,
        sensitivity: 0.5,
        stopGuard: Duration.zero,
      );
      await c.start(_list(3));
      expect(c.index, 0);

      c.advance(); // simulate voice-complete / Done
      expect(c.index, 1);
      c.advance(); // re-entrant during advancing/playing -> ignored
      expect(c.index, 1);
      c.dispose();
    });

    test('completing the last phrase fires onListComplete exactly once',
        () async {
      final log = CallLog();
      var completes = 0;
      String? completedId;
      final c = SessionController(
        tts: FakeTtsService(log),
        vad: FakeVadService(log),
        voiceEnabled: false, // manual-only, deterministic
        sensitivity: 0.5,
        stopGuard: Duration.zero,
      )..onListComplete = (id) {
          completes++;
          completedId = id;
        };

      await c.start(_list(2));
      c.advance(); // 0 -> 1
      await Future<void>.delayed(Duration.zero);
      expect(c.phase, SessionPhase.listening);
      c.advance(); // 1 -> done
      await Future<void>.delayed(Duration.zero);

      expect(c.phase, SessionPhase.done);
      expect(completes, 1);
      expect(completedId, 'morning');
      c.dispose();
    });
  });
}
