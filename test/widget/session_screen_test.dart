import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/app_settings.dart';
import 'package:hesn/models/azkar.dart';
import 'package:hesn/screens/session_screen.dart';
import 'package:hesn/theme/app_theme.dart';

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

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );

void main() {
  testWidgets('Done and Skip are always present (voice disabled, US2)',
      (tester) async {
    final log = CallLog();
    await tester.pumpWidget(_wrap(SessionScreen(
      list: _list(2),
      settings:
          const AppSettings(voiceDetectionEnabled: false, handsFreeMode: false),
      tts: FakeTtsService(log),
      vad: FakeVadService(log),
      permissions: FakePermissionService(),
      storage: FakeStorageService(),
      stopGuard: Duration.zero,
    )));
    await tester.pumpAndSettle();

    expect(find.text('تم'), findsOneWidget);
    expect(find.text('تجاوز'), findsOneWidget);
    expect(log.events.contains('vad.start'), isFalse);
  });

  testWidgets('tapping تم advances to the next phrase', (tester) async {
    final log = CallLog();
    await tester.pumpWidget(_wrap(SessionScreen(
      list: _list(2),
      settings:
          const AppSettings(voiceDetectionEnabled: false, handsFreeMode: false),
      tts: FakeTtsService(log),
      vad: FakeVadService(log),
      permissions: FakePermissionService(),
      storage: FakeStorageService(),
      stopGuard: Duration.zero,
    )));
    await tester.pumpAndSettle();

    expect(find.text('١ / ٢'), findsOneWidget);
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    expect(find.text('٢ / ٢'), findsOneWidget);
  });

  testWidgets('system back mid-session prompts before leaving (PopScope guard)',
      (tester) async {
    final log = CallLog();
    await tester.pumpWidget(_wrap(SessionScreen(
      list: _list(2),
      settings:
          const AppSettings(voiceDetectionEnabled: false, handsFreeMode: false),
      tts: FakeTtsService(log),
      vad: FakeVadService(log),
      permissions: FakePermissionService(),
      storage: FakeStorageService(),
      stopGuard: Duration.zero,
    )));
    await tester.pumpAndSettle();

    // Simulate a system back gesture.
    final didPop =
        await tester.binding.handlePopRoute(); // PopScope intercepts.
    await tester.pumpAndSettle();

    // The route did NOT pop; instead a confirm dialog is shown.
    expect(didPop, isTrue); // handled by PopScope, not propagated
    expect(find.text('إنهاء الجلسة؟'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    expect(find.text('خروج'), findsOneWidget);

    // Choosing متابعة dismisses the dialog and stays in the session.
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('إنهاء الجلسة؟'), findsNothing);
    expect(find.text('١ / ٢'), findsOneWidget);
  });
}
