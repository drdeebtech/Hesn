import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/azkar.dart';
import 'package:hesn/session/session_controller.dart';
import 'package:hesn/session/session_phase.dart';

import '../fakes/fakes.dart';

AzkarList _list() => const AzkarList(
      id: 'morning',
      title: 'أذكار الصباح',
      items: [
        AzkarItem(
          id: 'm_1',
          type: AzkarType.dhikr,
          text: 'الذكر الأول',
          repeat: 3,
          countPhrase: 'ثلاث مرات',
          source: 'حصن المسلم',
        ),
        AzkarItem(
          id: 'm_2',
          type: AzkarType.dhikr,
          text: 'الذكر الثاني',
          repeat: 1,
          source: 'حصن المسلم',
        ),
      ],
    );

void main() {
  group('Hands-free / driving mode (US6)', () {
    test('announces count before reading; mic opens only after stop (INV-6)',
        () async {
      final log = CallLog();
      final tts = FakeTtsService(log);
      final vad = FakeVadService(log);
      final cue = FakeCueService(log);
      final c = SessionController(
        tts: tts,
        vad: vad,
        voiceEnabled: true,
        sensitivity: 0.5,
        handsFree: true,
        cue: cue,
        stopGuard: Duration.zero,
      );

      await c.start(_list());

      // Spoken order for the first item: session-start title, then the count
      // phrase, then the phrase text.
      expect(tts.spoken.take(3).toList(),
          ['أذكار الصباح', 'ثلاث مرات', 'الذكر الأول']);

      // INV-6: the mic (vad.start) only opens after a stop, never during
      // announcing/playing.
      final startIdx = log.events.indexOf('vad.start');
      final stopIdx = log.events.indexOf('stop');
      expect(stopIdx, greaterThanOrEqualTo(0));
      expect(startIdx, greaterThan(stopIdx));
      expect(c.phase, SessionPhase.listening);
      c.dispose();
    });

    test('voice-complete advances with no taps; transition cue fires', () async {
      final log = CallLog();
      final cue = FakeCueService(log);
      final c = SessionController(
        tts: FakeTtsService(log),
        vad: FakeVadService(log),
        voiceEnabled: true,
        sensitivity: 0.5,
        handsFree: true,
        cue: cue,
        stopGuard: Duration.zero,
      );
      await c.start(_list());
      expect(c.index, 0);
      c.advance(); // simulate voice-complete (no screen touch)
      expect(c.index, 1);
      expect(log.events.contains('cue'), isTrue); // transition cue played
      c.dispose();
    });

    test('no Arabic voice → text-only: nothing is spoken, session still runs',
        () async {
      final log = CallLog();
      final tts = FakeTtsService(log, arabicVoice: false);
      final c = SessionController(
        tts: tts,
        vad: FakeVadService(log),
        voiceEnabled: true,
        sensitivity: 0.5,
        handsFree: true,
        cue: FakeCueService(log),
        stopGuard: Duration.zero,
      );
      await c.start(_list());
      expect(tts.spoken, isEmpty); // text-only fallback (FR-028)
      expect(c.audioAvailable, isFalse);
      expect(c.phase, SessionPhase.listening);
      c.dispose();
    });
  });
}
