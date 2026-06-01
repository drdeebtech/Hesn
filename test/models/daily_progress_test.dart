import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/daily_progress.dart';

void main() {
  group('DailyProgress date-rollover (FR-012)', () {
    test('same day preserves flags', () {
      const p = DailyProgress(
        dateKey: '2026-06-01',
        morningCompleted: true,
      );
      final today = p.forToday('2026-06-01');
      expect(today.morningCompleted, isTrue);
      expect(today.eveningCompleted, isFalse);
    });

    test('new day resets both flags', () {
      const p = DailyProgress(
        dateKey: '2026-06-01',
        morningCompleted: true,
        eveningCompleted: true,
      );
      final today = p.forToday('2026-06-02');
      expect(today.dateKey, '2026-06-02');
      expect(today.morningCompleted, isFalse);
      expect(today.eveningCompleted, isFalse);
    });

    test('markCompleted sets only the targeted list', () {
      const p = DailyProgress(dateKey: '2026-06-01');
      final m = p.markCompleted('morning');
      expect(m.morningCompleted, isTrue);
      expect(m.eveningCompleted, isFalse);
    });

    test('dateKeyFor formats yyyy-MM-dd', () {
      expect(DailyProgress.dateKeyFor(DateTime(2026, 6, 1)), '2026-06-01');
      expect(DailyProgress.dateKeyFor(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });
}
