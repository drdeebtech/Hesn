import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/azkar.dart';
import 'package:hesn/session/announcer.dart';

AzkarItem _item({required int repeat, String? countPhrase}) => AzkarItem(
      id: 'x',
      type: AzkarType.dhikr,
      text: 'ذكر',
      repeat: repeat,
      countPhrase: countPhrase,
      source: 'حصن المسلم',
    );

void main() {
  const announcer = Announcer();

  group('Announcer (FR-025)', () {
    test('returns the canonical count phrase for repeat > 1', () {
      final item = _item(repeat: 3, countPhrase: 'ثلاث مرات');
      expect(announcer.countAnnouncement(item), 'ثلاث مرات');
    });

    test('returns null for a single recitation', () {
      expect(announcer.countAnnouncement(_item(repeat: 1)), isNull);
    });

    test('returns null when repeat > 1 but no phrase is present', () {
      expect(announcer.countAnnouncement(_item(repeat: 5)), isNull);
    });

    test('session start/complete cues use the list title', () {
      final list = AzkarList(
        id: 'morning',
        title: 'أذكار الصباح',
        items: [_item(repeat: 1)],
      );
      expect(announcer.sessionStart(list), 'أذكار الصباح');
      expect(announcer.sessionComplete(list), 'اكتملت أذكار الصباح');
    });
  });
}
